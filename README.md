#  Snipe Viewer (Native iOS)

App that utilizes the API of [SnipeIT](https://github.com/snipe/snipe-it/tree/master) a free open source IT asset/license management system to make a moble on the go version of the website. The original purpose of this app is to give access to people in our domain(only admins can look up assets) to have a quick/on the go look at details of assets like the name and location of such asset and be able to return it to wherever or whomever it belongs to. Most of our assets do not have a static place where they live so here and there they get missplaced and would be great to give them the ability of finding our where the assets go and not have to wait for us to figure it out. 
Out side of our users biggest thing stopping me from just using the website is the responsiveness of the website on the mobile version and that fact that it feels like doing stuff in the mobile web version is unfriendly to do. Now that the simple viewing of asset details is under constructions I can see a real benefit for quick actions for admin users so its quick and simple without having to fight the responsivity of the mobile site.

## Installation

App is still under construction and has ways to go before a beta release. Once it is ready for a beta release it will be pushed to TestFlight. If you are wanting to check it our independentlly, since this is writen for iOS in native language swift XCode is needed to run in a simulator or in your personal device. 

These are the versions that I am using/have in mind to support:
* XCode version: 15+
* iOS version: 16+

## Authentication

For now as a closed testing version I am using email/passowrd authentication via [Firebase](https://firebase.google.com/) with plans to make "Sign in with Google" available in the near future. To keep the app to be able to log in only with peopple withon our domain I have set rules as to who can view the data saved in FireStor. Hope to use the OU in our google admin console to set rules and roles in the future.
To keep the closed testing I have purposefully not made a "Sign up"/"Create User" button on the app yet, ideally users dont have to be created and are either pulled from google admin or just sign in with their provided google accounts.

 
## API Key distribution

Since regular users are not able to create API keys or look up assets then an API key generated from a dummy account will be stored safely in Firebase and each user will be able to retreive it. We dont want just anyone renameing or checking out assets so each user will have a role(admin or employee) and through logic we can show or hide different actions.

## Database

* User Account: contains uuid, email, password // uses Firebase authentication
* Data bucket: user.uuid, role:admin/employee, email, name, API_KEY, BASE_URL // should get made automatically after user creation for now it is manual

## Future implementations:

* Cloud functions to handle all of the SnipeAPI interactions so API_KEY and BASE_URL don't have to come back to the device
* App lockscreen widget for ease if access
* Sign in with Google
