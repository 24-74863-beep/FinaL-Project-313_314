// Wraps an async controller so any error goes to fail().
const { fail } = require('./errors');
const wrap = fn => (req, res) => fn(req, res).catch(err => fail(res, err));
module.exports = { wrap };
