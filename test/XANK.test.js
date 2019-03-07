const { constants, expectEvent, shouldFail } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;

const XANK = artifacts.require('XANK');

contract('PUKAO', function ([_, creator, investor]) {
  beforeEach(async function () {
    this.token = await XANK.new({ from: creator });
  });

  it('has a name', async function () {
    (await this.token.name()).should.equal('XANK');
  });

  it('has a symbol', async function () {
    (await this.token.symbol()).should.equal('XANK');
  });

  it('has 18 decimals', async function () {
    (await this.token.decimals()).should.be.bignumber.equal('18');
  });

  it('assigns the initial total supply to the creator', async function () {
    const totalSupply = await this.token.totalSupply();
    const creatorBalance = await this.token.balanceOf(creator);

    creatorBalance.should.be.bignumber.equal(totalSupply);

    await expectEvent.inConstruction(this.token, 'Transfer', {
      from: ZERO_ADDRESS,
      to: creator,
      value: totalSupply,
    });
  });

  it("transfer token to the investor", async function() {
    await this.token.transfer(investor, 1000, { from: creator });
    const investorBalance = await this.token.balanceOf(investor);
    investorBalance.should.be.bignumber.equal("1000");
  });

  it('lock well', async function () {
    await this.token.transfer(investor, 1000, { from: creator });
    await this.token.Lock(investor, 1000, { from: creator });
    const locked = await this.token.lockedOf(investor);
    locked.should.be.bignumber.equal("1000");
  });

  it('locked token cant be transfer', async function () {
    await this.token.transfer(investor, 1000, { from: creator });
    await this.token.Lock(investor, 999, { from: creator });
    await shouldFail.reverting(this.token.transfer(creator, 2, { from: investor }));
  });

  it('also not be allowed', async function () {
    await this.token.transfer(investor, 1000, { from: creator });
    await this.token.Lock(investor, 999, { from: creator });
    await shouldFail.reverting(this.token.approve(creator, 3, { from: investor }));
  });

  it('lock only by owner', async function () {
    await this.token.transfer(investor, 1000, { from: creator });
    await shouldFail.reverting(this.token.Lock(investor, 999, { from: investor }));
  });

  it('also release does', async function () {
    await this.token.transfer(investor, 1000, { from: creator });
    await this.token.Lock(investor, 999, { from: creator });
    await shouldFail.reverting(this.token.Release(investor, 999, { from: investor }));
  });
});
