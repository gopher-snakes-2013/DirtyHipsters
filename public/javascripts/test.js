SC.initialize({
  client_id: 'a269d947e6f37f92168dfb82fd55a246'
});
// find all sounds of buskers licensed under 'creative commons share alike'
SC.get('/tracks', { q: 'trostli', license: 'cc-by-sa' }, function(tracks) {
  console.log(tracks);
});