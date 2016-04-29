var agent = require('./_header');
var device = require('../_private/device');

var msg = agent.createMessage()
  .device(device)
  .alert('Hello Universe!')
  .badge(1)
  .category('KudosCategory')
  .send();
