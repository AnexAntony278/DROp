import 'dart:convert';
import 'package:drop/constants/constants.dart';
import 'package:drop/services/app_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:drop/services/input_validator.dart';
import 'package:lottie/lottie.dart';

Map<String, dynamic> _user = {};
final List<GlobalKey<FormState>> _formKeys = [
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
];

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _animationController;

  _changeCardTo(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
    _animationController.forward();
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2300));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 10),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Lottie.asset(
                                'assets/animations/BoxAnimation.json',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: _pageController,
                              children: [
                                LoginCard(
                                  cardChange: _changeCardTo,
                                ),
                                SignUpCard1(
                                  cardChange: _changeCardTo,
                                ),
                                SignUpCard2(
                                  cardChange: _changeCardTo,
                                ),
                                SignUpCard3(
                                  cardChange: _changeCardTo,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LoginCard extends StatefulWidget {
  final Function cardChange;
  const LoginCard({super.key, required this.cardChange});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final TextEditingController _usernameEditingController =
      TextEditingController();

  final TextEditingController _passwordEditingController =
      TextEditingController();
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      child: Card(
          child: Padding(
        padding:
            const EdgeInsets.only(top: 100, bottom: 50, left: 50, right: 50),
        child: Form(
          key: _formKeys[0],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Username / E-mail',
                    style: TextStyle(
                        fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _usernameEditingController,
                  ),
                  const Text(
                    'Password',
                    style: TextStyle(
                        fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _passwordEditingController,
                    obscureText: true,
                  ),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                        color: Colors.red, fontStyle: FontStyle.italic),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: _handleLogin, child: const Text('LOGIN')),
                  TextButton(
                      child: const Text(
                        'signup >>',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                      onPressed: () {
                        widget.cardChange(1);
                      })
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  _handleLogin() async {
    try {
      final response = await http.post(Uri.parse("$NODE_SERVER_URL/login"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name_or_email": _usernameEditingController.text,
            "password": _passwordEditingController.text
          }));
      if (response.statusCode == 200 && mounted) {
        Navigator.popAndPushNamed(context, 'homepage');
        await AppPreferencesService.instance.prefs
            .setString('user_token', jsonDecode(response.body)['user_token']);
      } else {
        setState(() {
          _errorMessage = response.body;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Login error:$e")));
      }
    }
  }
}

class SignUpCard1 extends StatefulWidget {
  final Function cardChange;
  const SignUpCard1({super.key, required this.cardChange});

  @override
  State<SignUpCard1> createState() => _SignUpCard1State();
}

class _SignUpCard1State extends State<SignUpCard1> {
  final TextEditingController _usernameEditingController =
      TextEditingController();

  final TextEditingController _emailEditingController = TextEditingController();

  final TextEditingController _phoneEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: Card(
          child: Padding(
        padding:
            const EdgeInsets.only(top: 100, bottom: 50, left: 50, right: 50),
        child: Form(
          key: _formKeys[1],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Username',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold)),
                  TextFormField(
                    validator: InputValidator.validateUsername,
                    controller: _usernameEditingController,
                  ),
                  const Text('E-Mail',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold)),
                  TextFormField(
                    validator: InputValidator.validateEmail,
                    controller: _emailEditingController,
                  ),
                  const Text('Mobile No.',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold)),
                  TextFormField(
                    validator: InputValidator.validateMobile,
                    controller: _phoneEditingController,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      child: const Text(
                        '<< login',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                      onPressed: () => {widget.cardChange(0)}),
                  TextButton(
                      onPressed: () {
                        if (_formKeys[1].currentState?.validate() ?? false) {
                          _user['name'] = _usernameEditingController.text;
                          _user['email'] = _emailEditingController.text;
                          _user['phone'] = _phoneEditingController.text;
                          widget.cardChange(2);
                        }
                      },
                      child: const Text(
                        'next >>',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      )),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}

class SignUpCard2 extends StatefulWidget {
  final Function cardChange;
  const SignUpCard2({super.key, required this.cardChange});

  @override
  State<SignUpCard2> createState() => _SignUpCard2State();
}

class _SignUpCard2State extends State<SignUpCard2> {
  List<String> roles = ["Manager", "Delivery Agent"];
  late String selectedRole;
  final TextEditingController managerEditingController =
      TextEditingController();

  void onRoleChange(String option) {
    setState(() {
      selectedRole = option;
    });
  }

  @override
  void initState() {
    selectedRole = roles[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.only(
                  top: 100, bottom: 50, left: 50, right: 50),
              child: Form(
                key: _formKeys[2],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Role:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RadioListTile(
                          title: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  roles[0],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.manage_accounts)
                              ],
                            ),
                          ),
                          value: roles[0],
                          groupValue: selectedRole,
                          onChanged: (option) => onRoleChange(option ?? ''),
                        ),
                        RadioListTile(
                            title: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(roles[1],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const Icon(Icons.delivery_dining)
                                ],
                              ),
                            ),
                            value: roles[1],
                            groupValue: selectedRole,
                            onChanged: (option) => onRoleChange(option ?? '')),
                        Text(
                          (selectedRole == 'Manager')
                              ? 'Monitor and manage multiple delivery agents'
                              : 'Create and view optimized Delivery routes',
                          style: const TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 14),
                        )
                      ],
                    ),
                    if (selectedRole == 'Delivery Agent')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manager E-mail/Username if exists: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: managerEditingController,
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            child: const Text(
                              '<< back',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic),
                            ),
                            onPressed: () => {widget.cardChange(1)}),
                        TextButton(
                            onPressed: () {
                              if (_formKeys[2].currentState?.validate() ??
                                  false) {
                                _user['role'] = selectedRole;
                                _user['mangerId'] =
                                    managerEditingController.text;
                                widget.cardChange(3);
                              }
                            },
                            child: const Text('next >>')),
                      ],
                    )
                  ],
                ),
              ))),
    );
  }
}

class SignUpCard3 extends StatefulWidget {
  final Function cardChange;
  const SignUpCard3({super.key, required this.cardChange});

  @override
  State<SignUpCard3> createState() => _SignUpCard3State();
}

class _SignUpCard3State extends State<SignUpCard3> {
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordEditingController =
      TextEditingController();

  @override
  void dispose() {
    _passwordEditingController.dispose();
    _confirmPasswordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 100, bottom: 50, left: 50, right: 50),
          child: Form(
            key: _formKeys[3],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold)),
                    TextFormField(
                        validator: InputValidator.validatePassword,
                        controller: _passwordEditingController),
                    const SizedBox(height: 20),
                    const Text('Confirm Password',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold)),
                    TextFormField(
                      validator: (value) => InputValidator.confirmPassword(
                          value, _passwordEditingController.text),
                      controller: _confirmPasswordEditingController,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('<< back',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic)),
                      onPressed: () => widget.cardChange(2),
                    ),
                    ElevatedButton(
                        onPressed: handleSignup, child: const Text('SIGN UP')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleSignup() async {
    if (_formKeys[3].currentState?.validate() ?? false) {
      _user['password'] = _passwordEditingController.text;
      try {
        final response = await http.post(
          Uri.parse("$NODE_SERVER_URL/signup"),
          body: jsonEncode(_user),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200 && mounted) {
          Navigator.popAndPushNamed(context, 'homepage');
          await AppPreferencesService.instance.prefs
              .setString('user_token', jsonDecode(response.body)['user_token']);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login error:${response.body}")));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("SignIn error:$e")));
        }
      }
    }
  }
}
