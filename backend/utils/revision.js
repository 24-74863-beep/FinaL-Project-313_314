// Revision counter: goes up on every change so clients know when to reload their data.
let rev = 1;
const current = () => rev;
const touch = res => { rev++; res.set('X-Rev', String(rev)); };
const middleware = (req, res, next) => { res.set('X-Rev', String(rev)); res.set('Cache-Control', 'no-store'); next(); };
module.exports = { current, touch, middleware };
