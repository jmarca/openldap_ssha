/* global require console Buffer*/

var crypto = require('crypto');

function ssha_pass(passwd, salt, next) {
    function _ssha (passwd,salt,next ){
        var ctx = crypto.createHash('sha1');
        ctx.update(passwd);
        ctx.update(salt);
        var digest = ctx.digest();
        var ssha = '{SSHA}' + new Buffer(digest+salt,'binary').toString('base64');
        return next(null, ssha);
    }
    if(next === undefined) {
            next = salt;
            salt = null;
    }
    if(salt === null ){
        crypto.randomBytes(32, function(ex, buf) {
            if (ex) return next(ex);
            _ssha(passwd,buf.toString('base64') ,next);
            return null;
        });
    }else{
        _ssha(passwd,salt,next);
    }
    return null;
}

function checkssha(passwd, hash, next) {
    if (hash.substr(0,6) != '{SSHA}') {
        return false;
    }
    var bhash = new Buffer(hash.substr(6),'base64');
    var salt = bhash.toString('binary',20); // sha1 digests are 20 bytes long
    ssha_pass(passwd,salt,function(err,newssha){
        if(err) return next(err)
        return next(null,hash === newssha)
    });
    return null;
}

exports.checkssha = checkssha;
exports.ssha_pass = ssha_pass;
