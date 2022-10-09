const { createCredential, loadXLH, setServerUrl } = require("./ApexLink");

// setServerUrl("http://localhost:8080/");
setServerUrl("https://a12x41wd91.execute-api.us-east-1.amazonaws.com/default/server");

(async () => {
    let userId = `User-${(new Date().getTime())}`;
    let credential = await createCredential(userId);
    let link = await credential.linkToApex();
    let sso = await link.createSSOToken();
    console.log(sso);
    let pin = "4309";
    let xlh = link.credential.toXLH(pin);
    await new Promise((res)=>{
        setTimeout(res,5000);
    });
    try {
        let fakeUserId = `pukemo-${new Date().getTime()}`;
        let fakeLink = await loadXLH(xlh, fakeUserId, pin);
        let fakeSSO = await fakeLink.createSSOToken();
        console.log(fakeSSO);        
    } catch (e) {
        console.trace(e);
    }
    let trueLink = await loadXLH(xlh,userId,pin);
    let trueSSO = await trueLink.createSSOToken();
    console.log(trueSSO);
});

// (async () => {
//     try{
//         let serverId = "Svr:e-" + (new Date().getTime());
//         let serverCredential = await createCredential(serverId);
//         let serverLink = await serverCredential.linkToApex();
//         for (let i = 0; i < 2048; i+=4) {
//             let promises = [i,i+1,i+2,i+3].map(j=>(async()=>{
//                 let start = new Date().getTime();
//                 let userId = `User-${(new Date().getTime())}-${j}`;
//                 let credential = await createCredential(userId);
//                 // console.log("got credential", credential);
//                 let link = await credential.linkToApex();
//                 // console.log("created link");
//                 let ssoToken = await link.createSSOToken();
//                 // console.log("created ssoToken", ssoToken);
//                 let verifyTokenResult = await serverLink.verifySSOToken(ssoToken, userId);
//                 console.log("server sso verified", verifyTokenResult);
//                 let xlhPin = 'xlhPin';
//                 let xlh = link.credential.toXLH(xlhPin);
//                 console.log("xlh", xlh);
//                 let recoveredLink = await loadXLH(xlh, userId, xlhPin);
//                 console.log("recovered credential", recoveredLink.credential);
//                 let recreatedSSOToken = await recoveredLink.createSSOToken();
//                 console.log("recreated ssoToken", recreatedSSOToken);
//                 let reverifyTokenResult = await serverLink.verifySSOToken(recreatedSSOToken, userId);
//                 console.log("server sso verified2", reverifyTokenResult);
//                 console.log(`pass #${j} passed in ${new Date().getTime()-start} millis.`);
//             })());
//             await Promise.all(promises);
//         }
//     } catch(err){
//         console.debug(err);
//     }
// });
