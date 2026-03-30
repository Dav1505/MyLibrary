# MyLibrary

MyLibrary is a mobile application developed in Flutter which aims to help every book lover
in the world.

## Main Features

The application presents itself with a login page, where you can either access your account 
or create a new one. At the moment you can enter a fake email, just to test, as long as it
respects the correct syntax of an email address.

Once inside the app, you'll find a navigation bar with three main pages:

-Home Page: here you can find your personal book catalog, at which you can add a new book 
by simply clicking on the search button, which will open a new page where you can search
for any book (GoogleBooks' API is used). By clicking on a book in the catalog, you will
transition to a new page showing some useful information about the book, as well as a box 
where you can add your personal notes and thoughts.

-AI Assistant: it's the latest addition to the app: a chatbot which makes calls to Gemini
to answer your questions about books and give you advice on what to read.

-User Page: in this page you can find the information related to your profile, as well as
a button to delete it. Keep in mind that the application keeps you logged in by default, so
to delete your account it could be needed to log out with the button at the top and log in
again.

The app is available both in Italian and in English; you can easily switch the language with
the button at the top (some strings may be still available only in Italian).

Also, the app has a button to switch between dark and light mode, and it supports MaterialYou
so it uses the same theme color as your device.

The data of your profile is stored on Firestore Database and for the authentication it's
used Fireauth.

Some files like .env and the directory android/app are not in this repository since they
contain sensible information.

The app is still open to improvements and new features.


Notes: there are still a pair of bug with the chatbot: sometimes 
the text is without spaces and if you close the keyboard while Gemini is generating the answer, it fails.