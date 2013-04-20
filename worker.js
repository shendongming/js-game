self.addEventListener('message', function(e)
{
  var data = e.data;
  switch (data.cmd)
  {
    case 'startWorker':
      self.postMessage('worker thread start now:' + data.msg);
      break;
    default:
      self.postMessage('default');
  }
}
, false);
