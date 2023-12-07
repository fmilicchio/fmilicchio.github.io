---
layout: landing
title: Art
description: Paintings and Drawings
image: assets/images/paintings.jpg
nav-menu: true
---

<!-- Main -->
<div id="main">
<section>
<div class="inner">

<section class="special">
	<p>Random stuff I found on the internet. All subjects belong to the respective artist, I just draw and paint them (watercolor, charcoal, hard pastels, soft pastels, mixed media). For watercolors: the painting is still wet.</p>
	<ul class="actions">
		<li><a href="#" class="button special icon fa-behance" id="countdown">Redirect in 5</a></li>
	</ul>
</section>

<script>
    var timeLeft = 5; // time in seconds for the countdown
    var countdownElement = document.getElementById('countdown');

    var timerId = setInterval(function() {
        timeLeft--;
        countdownElement.textContent = "Redirect in " + timeLeft;

        if (timeLeft <= 0) {
            clearInterval(timerId);
            window.location.href = 'https://www.behance.net/jcxz100h';
        }
    }, 1000);
</script>

</div>
</section>
</div>
