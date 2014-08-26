---
title: "Becoming Security Aware"
date: "2013-01-08"
author: "Owen"
type: "blog"
tags: [security]
---
[The Register](http://www.theregister.co.uk/2013/01/07/nullcrew_dhs_hack/)
published an interesting article yesterday describing how a website owned by
the Department for Homeland security was compromised.
<!--more-->
The attack used a [directory traversal
vulnerability](https://www.owasp.org/index.php/Path_Traversal). This attack
allows the attacker to access files and directories outside of the applications
web root folder.

The full details are in The Register article along with further comment from
Paul Ducklin from Sophos.

What I found most surprising however was my own reaction as a read the article.
The attack revolves around a URL of of the form:

    http://example.org/known/dir/download.php?file=somename.dat

that the attacker then abuses to give following form:

    http://example.org/known/dir/download.php?file=../../private.dat 

Note: the directory path of the file.

As soon as I read the first URL form it was obvious how the attack could be
executed, if the 'download.php' did not adequately validate the file name.
Identifying where the is a problem is the first step in being able to find a
solution.

I can only describe my reaction is as a result of becoming much more security
aware. Previously I would have looked at the URL and thought little or nothing
off it. Now, it leaps out of the screen as something evil. A threat and an
attack vector that needs to be closed. It acts as a warning to ensure that the
'download.php' script is carefully code reviewed. It acts as a trigger to
generate evil use cases that can be used to test the behaviour of the script.

The more others have a similar reaction to myself, the more difficult we make
the job of the attacker. That can only be good for all web users.

