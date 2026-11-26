// Same hashing as hashPw() in the frontend (src/services/database.js), so existing passwords stay valid.
const crypto = require('crypto');
const hashPw = pw => crypto.createHash('sha256').update('bobbys$' + pw + '$motoshop', 'utf8').digest('hex');
module.exports = { hashPw };
