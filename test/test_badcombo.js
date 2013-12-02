var should = require('should')
var ssha = require('../lib/ssha')
var crypto = require('crypto')


var passwd = 'foo';
var salt = 'saltt';

var randompass = crypto.randomBytes(32).toString('base64');

var known_hash = '{SSHA}c6AhsUGD7NfYyTofZoKiuP5MDqjAcKGi';

describe('reported issue 1',function(){
    describe('specific password and salt',function(){
        it('should be checkable',function(){
            ssha.ssha_pass(passwd,salt, function(err,hash){
                should.not.exist(err);
                should.exist(hash);
                ssha.checkssha(passwd,hash,function(err,result){
                    should.not.exist(err);
                    should.exist(result);
                    result.should.equal(true);
                })
            })
        })
    })
})
