import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/auth.dart';
import 'package:utsavlife/routes/mainpage.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = "/settings";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Account'),
              onTap: () {
                Navigator.pushNamed(context, AccountPage.routeName);
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            Divider(),
            ListTile(
              title: Text('Terms and Conditions'),
              onTap: () {
                Navigator.pushNamed(context, '/terms');
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            Divider(),
            ListTile(
              title: Text('Privacy Policy'),
              onTap: () {
                Navigator.pushNamed(context, '/privacy');
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  static const routeName = "/settings/account";

  void _showDeactivateConfirmation(BuildContext context,AuthProvider state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deactivate Account'),
          content: Text('Are you sure you want to deactivate your account?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Deactivate'),
              onPressed: () async {
                await deactivateAccount(state);
                await state.getUser();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account Deactivated")));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
void _showActivateConfirmation(BuildContext context,AuthProvider state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Activate Account'),
          content: Text('Are you sure you want to activate your account?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Activate'),
              onPressed: () async {
                await activateAccount(context.read<AuthProvider>());
                await state.getUser();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account Activated")));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context,AuthProvider state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async{
                await deleteAccount(state);

              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context,state,child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Account Settings'),
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title:state.user!.userActiveStatus==UserActiveStatus.active?Text('Deactivate Account'):Text('Activate Account'),
                  onTap: () {
                    if(state.user!.userActiveStatus==UserActiveStatus.active){
                    _showDeactivateConfirmation(context,state);
                    }else{
                      _showActivateConfirmation(context,state);
                    }
                  },
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                Divider(),
                ListTile(
                  title: Text('Delete Account'),
                  onTap: () {
                    _showDeleteConfirmation(context,state);
                    state.logout();
                    Navigator.pushNamedAndRemoveUntil(context, MainPage.routeName, (route) => false);
                  },
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
    );
  }
}
