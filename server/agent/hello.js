var agent = require('./_header');
var device = require('../_private/device');

var names = ["Jare", "Andrew", "Sarah", "Jorge"];
var tasks = ["did the dishes", "cleaned bathroom", "vacuumed", "took out trash"];

var getRandomItem = function(l) {
  return l[Math.floor(Math.random()*l.length)];
};

var person = getRandomItem(names);
var task = getRandomItem(tasks);
var msg = agent.createMessage()
  .device(device)
  .alert(person + " just " + task + "!")
  .set("person", person)
  .set("task", task)
  .badge(1)
  .category('KudosCategory')
  .sound('Hope.aif')
  .send();
