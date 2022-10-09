class ApexError extends Error {
    constructor(mesg) {
        super(mesg ?? "Unexpected Error");
        this.classes = [];
    }
    toString() {
        return `${this.classes.join(":")}::${this.message}`;
    }
}

class SyntaxError extends ApexError {
    constructor(mesg) {
        super(mesg ?? "Unknown Syntax");
        this.classes.push("syntax_error");
    }
}

class AuthError extends ApexError {
    constructor(mesg) {
        super(mesg ?? "Authentication failed");
        this.classes.push("auth_error");
    }
}

class InternalError extends ApexError {
    constructor(excepton) {
        super(`Internal error - ${excepton?.message ?? "Unknown"}`);
        this.classes.push("internal_error");
    }
}

class PreconditionError extends ApexError {
    constructor(mesg) {
        super(mesg ?? "Precondition error");
        this.classes.push("precondition_error");
    }
}

class TagBoundError extends PreconditionError {
    constructor(mesg) {
        super(mesg ?? `Tag already bound to another id`);
        this.classes.push("tag_bound");
    }
}

class UserExistsError extends PreconditionError {
    constructor(mesg) {
        super(mesg ?? `User already exists`);
        this.classes.push("user_exists");
    }
}

class TokenNotExistsError extends PreconditionError {
    constructor(mesg) {
        super(mesg ?? `Token not exists`);
        this.classes.push("token_not_exists");
    }
}

class NoSuchUserError extends AuthError {
    constructor(mesg) {
        super(mesg ?? "Link user id not found");
        this.classes.push("no_such_user");
    }
}

class NoSuchTagError extends AuthError {
    constructor(mesg) {
        super(mesg ?? "Link tag not found");
        this.classes.push("no_such_tag");
    }
}

class SignNotExistError extends AuthError {
    constructor(mesg) {
        super(mesg ?? "User sign not available");
        this.classes.push("no_user_sign");
    }
}

class SignVerifyError extends AuthError {
    constructor(mesg) {
        super(mesg ?? "Sign Verification Failed");
        this.classes.push("sign_not_verified");
    }
}

class DatabaseError extends InternalError {
    constructor(dbException) {
        super(`Database Error - ${dbException?.message ?? "Unknown"}`);
        this.classes.push("database_error");
    }
}

const parse = (errorText) => {
    let [classes, description] = errorText.split("::");
    if (description == "") description = undefined;
    switch (classes) {
        case "syntax_error": return new SyntaxError(description);
        case "auth_error": return new AuthError(description);
        case "auth_error:no_such_user": return new NoSuchUserError(description);
        case "auth_error:no_such_tag": return new NoSuchTagError(description);
        case "auth_error:no_user_sign": return new SignNotExistError(description);
        case "auth_error:sign_not_verified": return new SignVerifyError(description);
        case "internal_error": return new InternalError(description);
        case "internal_error:database_error": return new DatabaseError(description);
        case "precondition_error": return new PreconditionError(description);
        case "precondition_error:tag_bound": return new TagBoundError(description);
        case "precondition_error:user_exists": return new UserExistsError(description);
        case "precondition_error:token_not_exists": return new TokenNotExistsError(description);
        default:
            return new ApexError(`Unknown Error ${errorText}`);
    }
}

module.exports = {
    InternalError,
    ApexError,
    AuthError,
    SyntaxError,
    PreconditionError,
    UserExistsError,
    TokenNotExistsError,
    NoSuchTagError,
    NoSuchUserError,
    TagBoundError,
    SignNotExistError,
    SignVerifyError,
    DatabaseError,
    parse
};