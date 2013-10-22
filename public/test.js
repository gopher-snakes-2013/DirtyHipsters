function playMusic(genre){
	SC.get('/tracks', {
		genres: genre,
		bpm: {
			from: 100
		}
	}, function(tracks) {
			var random = Math.floor(Math.random() * 49);
			SC.oEmbed(tracks[random].uri, { auto_play: true }, document.getElementById('target'));
	});
}

window.onload = function() {
	SC.initialize({
		client_id: 'd98651f44f2fe243e013f4c733c94de9'
	});

	var menuLinks = document.getElementsByClassName('genre');
	for (i = 0; i < menuLinks.length; i++){
		var menuLink = menuLinks[i];
		menuLink.onclick = function(e) {
			e.preventDefault();
			playMusic(menuLink.innerHTML);
		}
	}
};