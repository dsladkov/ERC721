import {time, loadFixture, hre, ethers, expect, anyValue, SignerWithAddress} from "./setup";

describe("MyToken", function() {
  async function deploy() {
    const [owner, user] = await ethers.getSigners();

    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy();
    await myToken.waitForDeployment();

    return {myToken, owner, user};
  }

  it("work", async function() {
    const {myToken, owner, user} = await loadFixture(deploy);

    console.log(myToken.target);
  });

  it("can't min to zero address", async function () {
    const {myToken, owner, user} = await loadFixture(deploy);

    const safeMintTx = myToken.safeMint(ethers.getAddress("0x0000000000000000000000000000000000000000"), "bafkreiguanphv2g276xudwfecszxzyta4ryrnbegjkkpdce37cbapnyykq");

    await expect(safeMintTx).revertedWith("zero address to");
  });

  it("shouldn't possible to mint if not an owner", async function () {
    const {myToken, owner, user} = await loadFixture(deploy);

    const safeMintTx = myToken.connect(user).safeMint(ethers.getAddress("0x0000000000000000000000000000000000000000"), "bafkreiguanphv2g276xudwfecszxzyta4ryrnbegjkkpdce37cbapnyykq");

    await expect(safeMintTx).revertedWith("Not an owner");
  });

  it("should possible to safeMint NFT", async function(){
    const {myToken, owner, user} = await loadFixture(deploy);
    const tokenId = "bafkreiguanphv2g276xudwfecszxzyta4ryrnbegjkkpdce37cbapnyykq";
    const safeMint = await myToken.safeMint(owner.address, tokenId);
    await safeMint.wait();


    const ownerOfNft = await myToken.ownerOf(0);
    expect(ownerOfNft).eq(owner.address);

    expect(await myToken.balanceOf(owner.address)).eq(1);
  });

  it("should possible to get tokenURI", async function(){
    const {myToken, owner, user} = await loadFixture(deploy);
    const tokenId = "bafkreiguanphv2g276xudwfecszxzyta4ryrnbegjkkpdce37cbapnyykq";
    const safeMint = await myToken.safeMint(owner.address, tokenId);
    await safeMint.wait();

    expect(await myToken.tokenURI(0)).eq("ipfs://" + tokenId );
  });

  describe("ERC721", function() {
    it("address owner cannot be zero", async function () {
      const {myToken, owner, user} = await loadFixture(deploy);
  
      const balanceOfTx = myToken.balanceOf(ethers.getAddress("0x0000000000000000000000000000000000000000"));
      //await safeMintTx.wait();
  
  
      await expect(balanceOfTx).revertedWith("Owner cannot be zero");
    });

    it("token name should abe as expected", async function() {
      const {myToken, owner, user} = await loadFixture(deploy);

      const tokenName = await myToken.name();
      expect(tokenName).eq("MyToken");
    });
    it("token symbol should be as expected", async function() {
      const {myToken, owner, user} = await loadFixture(deploy);

      const tokenSymbol = await myToken.symbol();
      expect(tokenSymbol).eq("MTK");
    });

    it("should possible to balanceOf address with NFT", async function(){
      const {myToken, owner, user} = await loadFixture(deploy);
      const tokenId = "bafkreiguanphv2g276xudwfecszxzyta4ryrnbegjkkpdce37cbapnyykq";
      const safeMint = await myToken.safeMint(owner.address, tokenId);
      await safeMint.wait();

      expect(await myToken.balanceOf(owner.address)).eq(1);
    });
  });
  


});