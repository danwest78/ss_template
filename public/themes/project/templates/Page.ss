<!DOCTYPE html>
<!--[if lt IE 7]><html class="ie ie6 lt-ie7 lt-ie8 lt-ie9" lang="en"><![endif]-->
<!--[if IE 7]><html class="ie ie7 lt-ie8 lt-ie9" lang="en"><![endif]-->
<!--[if IE 8]><html class="ie ie8 lt-ie9" lang="en"><![endif]-->
<!--[if IE 9]><html class="ie ie9 lt-ie10" lang="en"><![endif]-->
<!--[if IE]><html class="ie" lang="en"><![endif]-->
<!--[if !IE]><!--><html lang="en"><!--<![endif]-->
<head>
	<% base_tag %>
        <title>$Meta('Title')</title>

        <!-- Such meta -->
        <meta charset="utf-8">
        <meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
        <meta name="format-detection" content="telephone=no">

        <!-- SS Meta -->
        $MetaTags(false)

        <!-- basic meta -->
        <meta name="keywords" content="$Meta('Keywords')">
        <meta name="description" content="$Meta('Description')">
        <link rel="canonical" href="$Meta('Link')">

        <!-- Schema.org markup for Google+ -->
        <meta itemprop="name" content="$Meta('Title')">
        <meta itemprop="description" content="$Meta('Description')">
        <meta itemprop="image" content="$Meta('Image')">
        <meta itemprop="url" content="$Meta('Link')" />

        <!-- Twitter Card data -->
        <meta name="twitter:card" content="summary_large_image">
        <!-- <meta name="twitter:site" content="@publisher_handle"> -->
        <meta name="twitter:title" content="$Meta('Title')">
        <meta name="twitter:description" content="$Meta('Description')">
        <!-- <meta name="twitter:creator" content="@author_handle"> -->
        <meta name="twitter:image:src" content="$Meta('Image')">

        <!-- Open Graph data -->
        <meta property="og:title" content="$Meta('Title')" />
        <meta property="og:type" content="article" />
        <meta property="og:url" content="$Meta('Link')" />
        <meta property="og:image" content="$Meta('Image')" />
        <meta property="og:description" content="$Meta('Description')" />
        <meta property="og:site_name" content="$Meta('SiteName')" />
        <meta property="article:published_time" content="$Meta('TimeCreated')" />
        <meta property="article:modified_time" content="$Meta('TimeModified')" />
        <!-- <meta property="article:section" content="Article Section" /> -->
        <!-- <meta property="article:tag" content="Article Tag" /> -->
        <!-- <meta property="fb:admins" content="Facebook numberic ID" /> -->

        <!-- Favicons -->
        <link rel="shortcut icon" href="/$ThemeDir/assets/build/img/favicons/favicon.ico">
        <link rel="apple-touch-icon" sizes="57x57" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-57x57.png">
        <link rel="apple-touch-icon" sizes="114x114" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-114x114.png">
        <link rel="apple-touch-icon" sizes="72x72" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-72x72.png">
        <link rel="apple-touch-icon" sizes="144x144" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-144x144.png">
        <link rel="apple-touch-icon" sizes="60x60" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-60x60.png">
        <link rel="apple-touch-icon" sizes="120x120" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-120x120.png">
        <link rel="apple-touch-icon" sizes="76x76" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-76x76.png">
        <link rel="apple-touch-icon" sizes="152x152" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-152x152.png">
        <link rel="apple-touch-icon" sizes="180x180" href="/$ThemeDir/assets/build/img/favicons/apple-touch-icon-180x180.png">
        <link rel="icon" type="image/png" href="/$ThemeDir/assets/build/img/favicons/favicon-192x192.png" sizes="192x192">
        <link rel="icon" type="image/png" href="/$ThemeDir/assets/build/img/favicons/favicon-160x160.png" sizes="160x160">
        <link rel="icon" type="image/png" href="/$ThemeDir/assets/build/img/favicons/favicon-96x96.png" sizes="96x96">
        <link rel="icon" type="image/png" href="/$ThemeDir/assets/build/img/favicons/favicon-16x16.png" sizes="16x16">
        <link rel="icon" type="image/png" href="/$ThemeDir/assets/build/img/favicons/favicon-32x32.png" sizes="32x32">
        <meta name="msapplication-TileColor" content="#fafafa">
        <meta name="msapplication-TileImage" content="/$ThemeDir/assets/build/img/favicons/mstile-144x144.png">
        <meta name="msapplication-config" content="/$ThemeDir/assets/build/img/favicons/browserconfig.xml">

        <!-- SS wont render stuff where you say you want it -->
        <script src="themes/project/assets/build/js/lib-predom.js"></script>

        <!-- SS wont render stuff where you say you want it -->
        <!--[if IE]>
            <link rel="stylesheet" type="text/css" href="/themes/project/assets/build/css/blessed/main.css">
        <![endif]-->
        <!--[if !(IE)]><!-->
            <link rel="stylesheet" type="text/css" href="/themes/project/assets/build/css/main.css">
        <!--<![endif]-->
</head>


<body>

	<% include Header %>

	<main role="main">
			$Content
	</main>

	<% include Footer %>

	<% if $Env == 'development' %>
        <script src="/themes/project/assets/build/js/lib-postdom.js"></script>
        <script src="/themes/project/assets/src/js/app.js"></script>
    <% else %>
        <script src="/themes/project/assets/build/js/all.js"></script>
    <% end_if %>

</body>
</html>
