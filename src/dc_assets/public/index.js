import dc from 'ic:canisters/dc';

dc.greet(window.prompt("Enter your name:")).then(greeting => {
  window.alert(greeting);
});
