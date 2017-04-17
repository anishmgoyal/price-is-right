# Price is Right

### Overview

Simple implementation of the game, "The Price is Right", except that you ARE
allowed to go over the actual price. Closest score wins.

This implementation is fairly hacky, but that's partially because I wrote it
in about three hours to supplement a group project presentation.

### Configuration

Setting up the rails application is not very difficult. You can do the usual
```rake db:migrate``` followed by ```rails server```, or spend some time
configuring a different server like Puma.

To configure, log in as admin. By default, you can do this by going to the site,
and choosing "admin" as your nickname. The password field pops up when you do
this - the password is "price is right". This can be changed in the 
```user_controller```.

Once logged in as admin, you can click on the words "The Price Is Right" at the
top of the page to enter admin view. This allows you to create new questions,
delete existing ones, or reorder questions (only option provided is
move to bottom, since again - this is hacky. It just deletes and recreates the
question as is, which gives it a lower id, thus moving it to the bottom - LOL).

By default, correct answers are hidden in this view; they can be revealed by
clicking "Show Prices".

You can return to the game by clicking the "Home" button.

### Playing

Initially, when users connect to the app, they are shown a "Waiting" screen.
Play does not begin until an admin has officially signed on, at least one
question has been added, and the admin has navigated to at least one question.

The admin controls which question players can see. Click the "Last" button to
move back one question, or the "Next" button to load the next question. These 
actions automatically move all users to the question you have selected.

You can also go to a specific question by selecting its image in the admin panel.

When viewing a question, you get a semi-live count of the number of users who
have submitted an answer to a question. You can find the closest answer by clicking
"Get Scores" - you will also get the correct answer when you do this.

Scores are not currently tracked (remember, hacky?).