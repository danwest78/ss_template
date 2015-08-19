<header class="header" role="banner">
	<div class="inner">
		<div class="">
			<a href="$BaseHref" class="brand" rel="home">
				<h1>$SiteConfig.Title</h1>
				<% if $SiteConfig.Tagline %>
				<p>$SiteConfig.Tagline</p>
				<% end_if %>
			</a>

			<% include Navigation %>
		</div>
	</div>
</header>
