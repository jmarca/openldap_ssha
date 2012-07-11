var should = require('should')
var ssha = require('../lib/ssha')
var crypto = require('crypto')


var passwd = 'secret';
var salt = 'salt';

var randompass = crypto.randomBytes(32).toString('base64');

var known_hash = '{SSHA}c6AhsUGD7NfYyTofZoKiuP5MDqjAcKGi';

describe('ssha_pass',function(){
    describe('known password and salt',function(){
        it('should equal the value from Perl code',function(){
            ssha.ssha_pass(passwd, 'salt' , function(err,hash){
                should.not.exist(err);
                should.exist(hash);
                hash.should.equal('{SSHA}gVK8WC9YyFT1gMsQHTGCgT3sSv5zYWx0');
                ssha.checkssha(passwd,hash,function(err,result){
                    should.not.exist(err);
                    should.exist(result);
                    result.should.equal(true);
                })
            })
        })
    })
    describe('arbitrary password and salt',function(){
        it('should be checkable',function(){
            ssha.ssha_pass(randompass, function(err,hash){
                should.not.exist(err);
                should.exist(hash);
                ssha.checkssha(randompass,hash,function(err,result){
                    should.not.exist(err);
                    should.exist(result);
                    result.should.equal(true);
                })
            })
        })
    })

})
describe('checkssha',function(){
    describe('known password and hash',function(){
        it('should verify the value from slappasswd code',function(){
            ssha.checkssha(passwd,known_hash,function(err,result){
                should.not.exist(err);
                should.exist(result);
                result.should.equal(true);
            })
        })
    })
})
