<nav role="navigation" class="nav-primary">
	<ul>
		<% loop $Menu(1) %>
			<li class="$LinkingMode"><a href="$Link">$MenuTitle</a></li>
		<% end_loop %>
	</ul>
</nav>
