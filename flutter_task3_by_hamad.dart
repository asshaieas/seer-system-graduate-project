import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SeerApp());
}

class SeerApp extends StatelessWidget {
  const SeerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEER',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;
        final role = user.displayName;

        if (role == 'Parent') {
          return const ParentHomeScreen();
        }

        if (role == 'Driver') {
          return const DriverHomeScreen();
        }

        return const RoleSelectionScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMessage('Please enter email and password.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Login failed.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_bus_rounded,
                    size: 90,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'SEER',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Smart School Bus System',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 17),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Create New Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = 'Parent';
  bool isLoading = false;

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage('Please complete all fields.');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(selectedRole);
      await credential.user?.reload();

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Registration failed.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.person_add_alt_1,
                  size: 75,
                  color: Colors.blue,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'User Role',
                    prefixIcon: Icon(Icons.manage_accounts),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Parent',
                      child: Text('Parent'),
                    ),
                    DropdownMenuItem(
                      value: 'Driver',
                      child: Text('Driver'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 17),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String role = 'Parent';

  Future<void> saveRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updateDisplayName(role);
      await user.reload();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => role == 'Parent'
                ? const ParentHomeScreen()
                : const DriverHomeScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: const InputDecoration(
                labelText: 'Select your role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Parent',
                  child: Text('Parent'),
                ),
                DropdownMenuItem(
                  value: 'Driver',
                  child: Text('Driver'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  role = value!;
                });
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveRole,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEER - Parent'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parent Dashboard',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.child_care,
                  color: Colors.blue,
                ),
                title: Text('My Children'),
                subtitle: Text('View student information'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Colors.blue,
                ),
                title: Text('Track School Bus'),
                subtitle: Text('View real-time bus location'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: Colors.blue,
                ),
                title: Text('Notifications'),
                subtitle: Text('View boarding and alighting updates'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEER - Driver'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Dashboard',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.people,
                  color: Colors.blue,
                ),
                title: Text('Assigned Students'),
                subtitle: Text('View students assigned to your bus'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.directions_bus,
                  color: Colors.blue,
                ),
                title: Text('Current Trip'),
                subtitle: Text('View current trip information'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.warning_amber,
                  color: Colors.blue,
                ),
                title: Text('Safety Status'),
                subtitle: Text('View trip safety information'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}