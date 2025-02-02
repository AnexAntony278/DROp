import 'dart:convert';
import 'package:drop/constants/constants.dart';
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
//TODO: solve textfield problem
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

class LoginCard extends StatelessWidget {
  final Function cardChange;
  LoginCard({super.key, required this.cardChange});

  final TextEditingController usernameEditingController =
      TextEditingController();
  final TextEditingController passwordEditingController =
      TextEditingController();

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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    controller: usernameEditingController,
                  ),
                  const Text(
                    'Password',
                    style: TextStyle(
                        fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: passwordEditingController,
                    obscureText: true,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // TODO: Authenticate Login
                        if (true) {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, 'homepage');
                        }
                      },
                      child: const Text('LOGIN')),
                  TextButton(
                      child: const Text(
                        'signup >>',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                      onPressed: () {
                        cardChange(1);
                      })
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}

class SignUpCard1 extends StatelessWidget {
  final Function cardChange;
  SignUpCard1({super.key, required this.cardChange});
  final TextEditingController usernameEditingController =
      TextEditingController();
  final TextEditingController emailEditingController = TextEditingController();
  final TextEditingController mobileEditingController = TextEditingController();
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
                  const Text('Username'),
                  TextFormField(
                    validator: InputValidator.validateUsername,
                    controller: usernameEditingController,
                  ),
                  const Text('E-Mail'),
                  TextFormField(
                    validator: InputValidator.validateEmail,
                    controller: emailEditingController,
                  ),
                  const Text('Mobile No.'),
                  TextFormField(
                    validator: InputValidator.validateMobile,
                    controller: mobileEditingController,
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
                      onPressed: () => {cardChange(0)}),
                  TextButton(
                      onPressed: () {
                        if (_formKeys[1].currentState?.validate() ?? false) {
                          _user['name'] = usernameEditingController.text;
                          _user['email'] = emailEditingController.text;
                          _user['mobile'] = mobileEditingController.text;
                          cardChange(2);
                        }
                        //DEBUGGING EASE
                        // cardChange(2);
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
                              } //DEBUGGING EASE
                              // widget.cardChange(3);
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

class SignUpCard3 extends StatelessWidget {
  final Function cardChange;
  SignUpCard3({super.key, required this.cardChange});
  final TextEditingController passwordEditingController =
      TextEditingController();
  final TextEditingController confirmPasswordEditingController =
      TextEditingController();
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(
                        fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    validator: InputValidator.validatePassword,
                    controller: passwordEditingController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      return InputValidator.confirmPassword(
                          value, passwordEditingController.text);
                    },
                    controller: confirmPasswordEditingController,
                  ),
                  const SizedBox(
                    height: 20,
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
                      onPressed: () => {cardChange(2)}),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKeys[3].currentState?.validate() ?? false) {
                          _user['password'] = passwordEditingController.text;
                          http.post(
                            Uri.http(NODE_SERVER_URL),
                            body: jsonEncode(_user),
                            headers: {'Content-Type': 'application/json'},
                          );
                        }
                      },
                      child: const Text('SIGN IN')),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
