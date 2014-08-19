c9.io setup script for checkbox
===============================

With this script, anyone can get a working checkbox development environment for
free, in minutes, on any OS. All you have to do is:

Get a c9.io account
===================

Go to https://c9.io and sign in with your github or bitbucket accounts.

Get a launchpad.net account
===========================

You'll need a launchpad to push your checkbox banches back to launchped.
Go to https://login.launchpad.net/+login to create an account if needed.

If you've never used c9.io with launchpad before, make sure to add your c9.io
ssh key to your launchpad account. Unfortunately there are no simple links for
that (ah, all those shiny 2.0 webapps). On c9.io go to your dashboard and click
on "Show your SSH key" on the right. Copy that key. On launchpad.net click on
your username in the top-right corner, click on the yellow circle/pencil icon
next to the "SSH keys" section. Paste in your key and save, you should be good
to go. 

Create a new workspace
======================

Go to your c9.io dashboard and create a new workspace, any name will do but you
can use 'checkbox' to know what it is for later on. Make sure to select the
'custom' workspace type then click on "create"

After the workspace is created click on the "start editing" button. This will
open a new tab/window specific for that workspace. In the new tab look at the
default window layout. You should have a terminal running at the bottom of the
page. You can open additional terminals with ALT+T.

Paste the following code:

 curl https://raw.githubusercontent.com/checkbox/c9-setup/master/c9-setup.sh | sh

Volia :-) You should be good to go now.
