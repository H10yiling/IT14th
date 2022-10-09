// https://stackoverflow.com/q/37450475/5206474

/**
 *  !! IMPORTANT !!
 *  
 *  1. ECC-related parameters exchanging with apex server should be considered as big-endian. 
 *  2. Randoms or hashes in ECC-related calculations should be also considered as big-endian.
 *  3. AES-related parameters exchanging with apex server should be considered as little-endian.
 *  4. On browser, Buffer class should be injected to window (bn.js issue).
 *  5. On browser, Buffer.toString("base64url") isn't working and should be replaced with external libraries(e.g. 'urlsafe-base64' from npm).
 * 
 */

if (global.window) window.Buffer = require("buffer").Buffer;
const { BN } = require('bn.js');
const crypto = require('crypto');
const { ec: EC } = require('elliptic');
const https = require('https');
const http = require('http');
const URLSafeBase64 = require('urlsafe-base64');
const { URL } = (global??window??URL) ?? require("url");
if (global.window) window.URL = URL;
const { parse:parseError, UserExistsError, TagBoundError} = require("./misc/errors");

let serverUrl = "https://apex.cmoremap.com.tw:8080/"; // default public server.

Buffer.prototype.duplicateReverse = function () { return Buffer.from([...this]).reverse(); };

const setServerUrl = (url) => {
    serverUrl = url;
}

// const os = require('os');
// console.log(os.endianness()); // Usually 'little'

const switcEndian = (hexString) => { // switch endian of a hex string.
    return hexString.match(/../g).duplicateReverse().join('');
}

let getTimeStampBuffer = () => { // create a timestamp buffer comes with apex-defined format.
    let buffer = Buffer.alloc(8);
    let now = new Date();
    let timestamp = new BN(now.getTime() + now.getTimezoneOffset() * 60 * 1000, 10, 'LE').toBuffer();
    buffer.set(timestamp, 0);
    return buffer;
}

const createUserIdBuffer = (userId) => { // create a user id buffer comes with apex-defined format.
    let buffer = Buffer.alloc(32);
    buffer.set(Buffer.from(userId, 'utf-8'), 0);
    return buffer;
};

const get_TS_Uint8Array = () => { // The one apex uses.
    var bytes = [];
    const now = new Date();
    var utcMilllisecondsSinceEpoch = now.getTime() +
        (now.getTimezoneOffset() * 60 * 1000);
    for (var c = 0; c < 8; c++) {
        var octet_value = utcMilllisecondsSinceEpoch % 256;
        utcMilllisecondsSinceEpoch =
            (utcMilllisecondsSinceEpoch - octet_value) / 256
        bytes.push(octet_value);
    }
    return Uint8Array.from(bytes);
}

const postToApex = (body) => new Promise((resolve, reject) => {
    let result = "";
    let url = new URL(serverUrl);
    let request = url.protocol === "https:" ? https.request : http.request;
    let start = new Date().getTime();
    request = request({
        method: 'POST',
        hostname: url.hostname,
        port: url.port,
        path: url.pathname,
        headers: {
            'Content-Type': 'text/plain'
        }
    }, res => {
        res.on('data', d => {
            // console.log("on-data");
            result += d;
        })
        res.on('end', () => {
            console.log(`http request costed ${new Date().getTime()-start}`);
            resolve(result);
        });
        res.on('error', e => {
            reject(e);
        });
    });
    request.write(body);
    request.end();
});

const sha256 = (data) => {
    return crypto.createHash('sha256').update(data).digest();
};

const aesGcmEncrypt = (key, data, iv) => {
    iv = iv || crypto.randomBytes(16);
    let cipher = crypto.createCipheriv('aes-256-gcm', key, iv, { authTagLength: 16 });
    return Buffer.concat([cipher.update(data), cipher.final()]);
};

const aesGcmDecrypt = (key, encrypted, iv) => {
    iv = iv || crypto.randomBytes(16);
    let decipher = crypto.createDecipheriv('aes-256-gcm', key, iv, { authTagLength: 16 });
    // decipher.setAAD(Buffer.alloc(iv.length)); // not very neccessary.
    // decipher.setAuthTag(Buffer.alloc(iv.length));
    return decipher.update(encrypted);
};

const createAESIV = (seed) => {
    let preIV = Buffer.concat([
        seed,
        getTimeStampBuffer(),
        crypto.randomBytes(8)
    ]);
    return { preIV, iv: sha256(preIV).subarray(0, 16) };
};

const postAESCommandToApex = async (key, payload, ivSeed) => {
    let { preIV, iv } = createAESIV(ivSeed);
    let atCommandPayload = Buffer.concat([
        preIV,
        aesGcmEncrypt(key, payload, iv)
    ]);
    let response = await postToApex(`AT,${URLSafeBase64.encode(atCommandPayload)}`);
    if (!response.startsWith("OK,")){
        if(response.startsWith("ERR,")){
            throw parseError(URLSafeBase64.decode(response.substring("ERR,".length)).toString("utf-8"));
        } else{
            throw parseError(response);
        }
    } 
    let resultBytes = URLSafeBase64.decode(response.substring(3));
    // console.log("resultBytes",resultBytes.toString('hex'));
    // console.log(resultBytes.length);
    let remoteIV = sha256(resultBytes.subarray(0, 24)).subarray(0, 16);
    // console.log("remoteIV",remoteIV.toString('hex'));
    let remotePayload = resultBytes.subarray(24);
    // console.log("remotePayload",remotePayload.toString('hex'));
    return aesGcmDecrypt(key, remotePayload, remoteIV);
}

class ApexCredential {
    constructor(userId, linkTag, linkKey, privateKey) {
        if (!userId || linkTag.length != 8 || linkKey.length != 32 || privateKey.length != 32) {
            console.log(arguments);
            throw `Invalid arguments`;
        }
        this.userId = userId;
        this.linkTag = linkTag;
        this.linkKey = linkKey;
        this.privateKey = privateKey;
    }
    async linkToApex() {
        return linkToApex(this);
    };
    toXLH(pin) {
        return toXLH(this, pin);
    }
}

class EphLink { // Temporary link for ECC-based authentication.
    constructor(privateKey, linkTag, linkKey) {
        this.privateKey = privateKey;
        this.linkTag = linkTag;
        this.linkKey = linkKey;
    }
}

class ApexLink {
    constructor(credential, ephLink) {
        this.credential = credential;
        this.ephLink = ephLink;
    }
    async createSSOToken() {
        return createSSOToken(this);
    }
    async verifySSOToken(token, userId) {
        return verifySSOToken(this, token, userId);
    }
}

const createEphLink = async (privateKey) => {
    let linkHandShake = crypto.createECDH('secp256k1');
    privateKey && linkHandShake.setPrivateKey(privateKey);
    privateKey || linkHandShake.generateKeys();
    let apexTimeStamp = getTimeStampBuffer();
    let linkPayload = Buffer.concat([
        linkHandShake.getPublicKey().subarray(1, 33).duplicateReverse(),
        linkHandShake.getPublicKey().subarray(33, 65).duplicateReverse(),
        apexTimeStamp
    ]);
    let linkResult = await postToApex(`LNK,${URLSafeBase64.encode(linkPayload)}`);
    if (!linkResult.startsWith("OK,")){
        if(linkResult.startsWith("ERR,")){
            throw parseError(URLSafeBase64.decode(linkResult.substring("ERR,".length)).toString("utf-8"));
        } else{
            throw parseError(linkResult);
        }
    }
    let resultBytes = URLSafeBase64.decode(linkResult.substring(3));
    let remoteX = resultBytes.subarray(0, 32).duplicateReverse(); // ECC-related parameters received from apex server are in big-endian format.
    let remoteY = resultBytes.subarray(32, 64).duplicateReverse();
    let remotePublicKey = Buffer.concat([
        Buffer.from([0x04]),
        remoteX,
        remoteY
    ])
    let secret = linkHandShake.computeSecret(remotePublicKey).duplicateReverse();
    let iv = sha256(resultBytes.subarray(64, 88)).subarray(0, 16);
    let encrypted = resultBytes.subarray(88);
    let decrypted = aesGcmDecrypt(secret, encrypted, iv);
    let linkTag = decrypted.subarray(0, 8)
    let linkKey = decrypted.subarray(8, 40);
    let remotePublicBx = decrypted.subarray(40, 72);
    let remotePublicBy = decrypted.subarray(72, 104);
    let linkPrivateKey = Buffer.alloc(32);
    let handshakePrivateKey = linkHandShake.getPrivateKey();
    linkPrivateKey.set(handshakePrivateKey,32-linkPrivateKey.length);
    return new EphLink(linkPrivateKey, linkTag, linkKey);
}

const confirmCedential = async (userId, linkTag, linkKey, privateKey) => {
    let linkHandShake = crypto.createECDH('secp256k1');
    linkHandShake.setPrivateKey(privateKey);
    let linkPublicX = linkHandShake.getPublicKey().subarray(1, 33);
    let linkPublicY = linkHandShake.getPublicKey().subarray(33, 65);
    let linkFirmPayload = Buffer.concat([
        Buffer.from("LNKfirm:", "utf-8"),
        crypto.randomBytes(8),
        linkPublicX.duplicateReverse(),
        linkPublicY.duplicateReverse(),
        createUserIdBuffer(userId)
    ]);
    let confirmResult = await postAESCommandToApex(linkKey, linkFirmPayload, linkTag);
    return confirmResult;
}

const createCredential = async (userId, ephLink) => {
    ephLink = ephLink || await createEphLink();
    let linkFirmResult = await confirmCedential(userId, ephLink.linkTag, ephLink.linkKey, ephLink.privateKey);
    if (!linkFirmResult.toString('utf-8').startsWith("LNK-ok !")) throw `Link firm failed, payload message: ${linkFirmResult.toString('utf-8')}`;
    return new ApexCredential(userId, ephLink.linkTag, ephLink.linkKey, ephLink.privateKey);
};

const refreshCredential = async (credential, ephLink) => {
    ephLink = ephLink || await createEphLink();
    try {
        let confirmResult = await confirmCedential(credential.userId, credential.linkTag, credential.linkKey, credential.privateKey);
    } catch (e) {
        if (e instanceof UserExistsError) console.log("ID alrady existed");
        else if(e instanceof TagBoundError) console.log("Tag already bound"); 
        else throw e;
    }
    return credential;
};

const createUserIdSignature = (credential, timeStamp, signKey) => {
    let ec = new EC('secp256k1');
    timeStamp = timeStamp || getTimeStampBuffer();
    let privateKey = ec.keyFromPrivate(signKey || credential.privateKey);
    let signMessageK = sha256(Buffer.concat([
        timeStamp,
        createUserIdBuffer(credential.userId),
    ])).duplicateReverse(); // !! reverse the hash to match the format of the signature.
    let signKValue = crypto.randomBytes(32).duplicateReverse(); // !! not very neccessary but for unifying.
    let signResult = privateKey.sign(signMessageK, "buffer", {
        k: () => new BN(signKValue.toString('hex'), 'hex')
    });
    let publics = Buffer.from(privateKey.getPublic('array'));
    let pubX = publics.subarray(1, 33);
    let pubY = publics.subarray(33, 65);
    return { pubX, pubY, r: signResult.r.toBuffer(undefined,32), s: signResult.s.toBuffer(undefined,32), timeStamp };

    // try using external module 'elliptic' can have a result more effeciently and do the signing.
    // let ec = new EC('secp256k1');
    // let alicePrivate = ec.keyFromPrivate(Buffer.from('f5bd4227f50798e5133cf3250d0f4c730e4c4c6084403826c3b3d4d59973c6d3','hex').reverse());
    // console.log(alicePrivate.getPublic('hex'));
    // let signMessageK = Buffer.from("d7b83ea00c753a9a8623373a3cad87d3abd937f386472b5b089740785d138cac",'hex').reverse();
    // let signKValue = Buffer.from("1c6f1d77e44d4b5a2cf8b3204dc7291a01a2cc36bfd0862fc0d757f5d670b7e5", 'hex').reverse();
    // let signResult = alicePrivate.sign(signMessageK, 'buffer', {
    //     k:()=>new BN(signKValue,'hex')
    // });
    // console.log(switchEndian(signResult.r.toBuffer().toString('hex'))); // This matches c++ calculated one.
    // console.log(switchEndian(signResult.s.toBuffer().toString('hex'))); // This matches c++ calculated one.

    /**
    Example values from kotlin/c++ :
    ecdsaMessagePrivate = f5bd4227f50798e5133cf3250d0f4c730e4c4c6084403826c3b3d4d59973c6d3
    ecdsaMessageK = d7b83ea00c753a9a8623373a3cad87d3abd937f386472b5b089740785d138cac
    ecdsaKValue = 1c6f1d77e44d4b5a2cf8b3204dc7291a01a2cc36bfd0862fc0d757f5d670b7e5
    ecdsaResult.x = 6cae80c91c0a947b6ce1184c1ed78ddd5855cbdbce3dbe6ff2436d2c776b62e6
    ecdsaResult.y = 55589b1b18f95f9e835168552c2ca6ad15fac68d41036afff9965a07f611fa85
    ecdsaResult.r = 0f5fea68475440ee1a6e1f3bdb8c93d8cd0be05321faa8de2f57416d5de6e534
    ecdsaResult.s = ff4001df1979497d7f37bbacca5d06da6de416c37b647f4b689cf0357e643e1c
     */
};

const verifySignature = (message, pubX, pubY, r, s) => {
    let ec = new EC('secp256k1');
    let publicKey = ec.keyFromPublic(Buffer.concat([
        Buffer.from([0x04]),
        pubX,
        pubY
    ]));
    return ec.verify(message, { r: r, s: s }, publicKey);
};

const verifyUserIdSignature = (userId, timeStamp, pubX, pubY, r, s) => {
    return verifySignature(sha256(Buffer.concat([timeStamp, userId])).duplicateReverse(), pubX, pubY, r, s);
}

const signToApex = async (linkOrCredential, updateEphLink) => {
    let link = linkOrCredential instanceof ApexLink ? linkOrCredential : new ApexLink(linkOrCredential);
    if (!(link.credential instanceof ApexCredential)) throw "Credential is not ApexCredential";
    let signature = createUserIdSignature(link.credential, getTimeStampBuffer());
    let ephemeralHandShake = crypto.createECDH('secp256k1');
    ephemeralHandShake.generateKeys();
    let signAuthPayloads = [
        Buffer.from("SasAuth:", "utf-8"),
        signature.timeStamp,
        signature.pubX.duplicateReverse(),
        signature.pubY.duplicateReverse(),
        signature.r.duplicateReverse(),
        signature.s.duplicateReverse(),
        createUserIdBuffer(link.credential.userId)
    ];
    if (updateEphLink || !link.ephLink) {
        signAuthPayloads.push(ephemeralHandShake.getPublicKey().subarray(1, 33).duplicateReverse());
        signAuthPayloads.push(ephemeralHandShake.getPublicKey().subarray(33, 65).duplicateReverse());
    }
    let signAuthPayload = Buffer.concat(signAuthPayloads);
    let signAuthResult = await postAESCommandToApex(link.credential.linkKey, signAuthPayload, link.credential.linkTag);
    if (!signAuthResult.toString('utf-8').startsWith("AuthOk !")) throw `Sign Auth failed, payload message: ${signAuthResult.toString('utf-8')}`;
    if (signAuthResult.length == 80) {
        link.ephLink = new EphLink(ephemeralHandShake.getPrivateKey(), signAuthResult.subarray(40, 48), signAuthResult.subarray(48, 80));
    }
    return link;
}

const linkToApex = async (credential) => {
    let link = await signToApex(credential);
    return link;
};

const depositSSOKey = async (link, forUser) => {
    if (!link.ephLink) link = await signToApex(link, true);
    let ssoKey = crypto.randomBytes(32);
    let ssoDepositPayloads = [
        Buffer.from("TKNdpst:", "utf-8"),
        ssoKey,
        createUserIdBuffer(link.credential.userId)
    ];
    if (forUser) {
        ssoDepositPayloads.push(createUserIdBuffer(forUser));
    }
    let ssoDepositPayload = Buffer.concat(ssoDepositPayloads);
    let ssoDepositResult = await postAESCommandToApex(link.credential.linkKey, ssoDepositPayload, link.credential.linkTag);
    if (!ssoDepositResult.toString('utf-8').startsWith("tkn_Ok !")) throw `SSO Deposit failed, payload message: ${ssoDepositResult.toString('utf-8')}`;
    let ssoTokenIndex = ssoDepositResult.subarray(8, 40);
    return { ssoKey, ssoTokenIndex };
};

const createSSOToken = async (link, forUser) => {
    let ssoDeposit = await depositSSOKey(link, forUser);
    let timestamp = getTimeStampBuffer();
    let userId = createUserIdBuffer(link.credential.userId);
    let preIV = Buffer.concat([
        crypto.randomBytes(8),
        timestamp,
        crypto.randomBytes(8)
    ]);
    let ssoSign = createUserIdSignature(link.credential, timestamp, link.ephLink.privateKey);
    // console.log(ssoSign.r.toString('hex'));
    // console.log(ssoSign.s.toString('hex'));
    let ssoPayload = Buffer.concat([
        Buffer.from("sso_apx:", "utf-8"),
        timestamp,
        userId,
        ssoSign.r.duplicateReverse(),
        ssoSign.s.duplicateReverse()
    ]);
    let iv = sha256(preIV).subarray(0, 16);
    ssoPayload = aesGcmEncrypt(ssoDeposit.ssoKey, ssoPayload, iv);
    let ssoData = Buffer.concat([
        ssoDeposit.ssoTokenIndex,
        preIV,
        ssoPayload
    ]);
    return URLSafeBase64.encode(ssoData);
};

const verifySSOToken = async (link, token, userId) => {
    userId = createUserIdBuffer(userId);
    let ssoData = URLSafeBase64.decode(token);
    let ssoTokenIndex = ssoData.subarray(0, 32);
    let preIV = ssoData.subarray(32, 56);
    let ssoPayload = ssoData.subarray(56);
    let iv = sha256(preIV).subarray(0, 16);

    let ssoKeyFetchPayloads = [
        Buffer.from("TKNftch:", "utf-8"),
        ssoTokenIndex
    ];
    let ssoKeyFetchPayload = Buffer.concat(ssoKeyFetchPayloads);
    let ssoKeyFetchResult = await postAESCommandToApex(link.credential.linkKey, ssoKeyFetchPayload, link.credential.linkTag);
    if (!ssoKeyFetchResult.toString('utf-8').startsWith("ftch_Ok!")) throw `SSO Key Fetch failed, payload message: ${ssoKeyFetchResult.toString('utf-8')}`;
    let ssoKey = ssoKeyFetchResult.subarray(8, 40);
    let ssoUserId = ssoKeyFetchResult.subarray(40, 72);
    if (userId && !ssoUserId.equals(userId)) throw "SSO Token userId mismatch, expected " + userId + ", got " + ssoUserId.toString('utf-8');
    let ssoPayloadDecrypted = aesGcmDecrypt(ssoKey, ssoPayload, iv);
    let ssoDecryptedTimestamp = ssoPayloadDecrypted.subarray(8, 16);
    let ssoDecryptedUserId = ssoPayloadDecrypted.subarray(16, 48);
    let ssoDecryptedSignatureR = ssoPayloadDecrypted.subarray(48, 80).duplicateReverse();
    let ssoDecryptedSignatureS = ssoPayloadDecrypted.subarray(80, 112).duplicateReverse();
    let getUserPublicKeyPayloads = [
        Buffer.from("GeePubK:", "utf-8"),
        ssoDecryptedUserId
    ];
    let getUserPublicKeyPayload = Buffer.concat(getUserPublicKeyPayloads);
    for(let retries=0;retries<10;retries++){
        try{
            let getUserPublicKeyResult = await postAESCommandToApex(link.credential.linkKey, getUserPublicKeyPayload, link.credential.linkTag);
            if (!getUserPublicKeyResult.toString('utf-8').startsWith('GepkOk !')) throw `User Public Key Fetch failed, payload message: ${getUserPublicKeyResult.toString('utf-8')}`;
            let userPublicX = getUserPublicKeyResult.subarray(8, 40).duplicateReverse();
            let userPublicY = getUserPublicKeyResult.subarray(40, 72).duplicateReverse();
            let signatureVerfyResult = verifyUserIdSignature(
                ssoDecryptedUserId,
                ssoDecryptedTimestamp,
                userPublicX,
                userPublicY,
                ssoDecryptedSignatureR,
                ssoDecryptedSignatureS
            );
            return signatureVerfyResult;
        } catch(e){
            if(retries==9) throw e;
            else console.log(`GeePubK: retrying ${retries+1}`);
        }
    }
};

const toXLH = (credential, pin) => {
    let preIVPadding = crypto.randomBytes(32);
    let preIV = Buffer.concat([
        Buffer.from(pin, "utf-8"),
        preIVPadding
    ]);
    let iv = sha256(preIV).subarray(0, 16);
    let xlhKey = sha256(Buffer.concat([
        preIVPadding,
        Buffer.from(pin, "utf-8")
    ]));
    let xlhPayload = Buffer.concat([
        credential.linkTag,
        credential.linkKey,
        credential.privateKey.duplicateReverse()
    ]);
    let xlhPayloadEncrypted = aesGcmEncrypt(xlhKey, xlhPayload, iv);
    let xlhData = Buffer.concat([
        preIVPadding,
        xlhPayloadEncrypted
    ]);
    return URLSafeBase64.encode(xlhData);
}

const fromXLH = async (xlh, userId, pin) => {
    let xlhData = URLSafeBase64.decode(xlh);
    let preIVPadding = xlhData.subarray(0, 32);
    let iv = sha256(Buffer.concat([
        Buffer.from(pin, "utf-8"),
        preIVPadding
    ])).subarray(0, 16);
    let xlhPayloadEncrypted = xlhData.subarray(32);
    let xlhKey = sha256(Buffer.concat([
        preIVPadding,
        Buffer.from(pin, "utf-8")
    ]));
    let xlhPayload = aesGcmDecrypt(xlhKey, xlhPayloadEncrypted, iv);
    let linkTag = xlhPayload.subarray(0, 8);
    let linkKey = xlhPayload.subarray(8, 40);
    let privateKey = xlhPayload.subarray(40, 72).duplicateReverse();
    let ephemLink = await createEphLink();
    let credential = await refreshCredential(new ApexCredential(userId, linkTag, linkKey, privateKey), ephemLink);
    let link = await signToApex(credential, true);
    return link;
};

module.exports = {
    setServerUrl,
    createCredential,
    loadXLH: fromXLH
};