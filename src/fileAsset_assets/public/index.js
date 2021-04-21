import fileAsset from 'ic:canisters/fileAsset';

fileAsset.greet(window.prompt("Enter your name:")).then(greeting => {
  window.alert(greeting);
});
