const HelloWorld = artifacts.require("HelloWorld");
contract("HelloWorld", (accounts) => {
  it("Hello World testing", async () => {
    const helloWorld = await HelloWorld.deployed();
    await helloWorld.setName("Ahmed");
    const result = await helloWorld.yourName();
    assert.equal(result, "Ahmed");
  });
});
