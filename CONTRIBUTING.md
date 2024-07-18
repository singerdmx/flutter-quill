# Contributing

First of all, we would like to thank you for your time and efforts on this project, we appreciate it

You can see tutorials online on how to contribute to any open source project, it's a simple process, and you can do it
even if you are not Git expert, simply start by forking the repository, clone it, create a new branch, make your
changes and commit them, then push the branch to your fork, and you will get link to send a PR to the upstream
repository

If you don't have anything specific in mind to improve or fix, you can take a look at the issues tab or take a look at
the todos of the project, they all start with `TODO:` so you can search in your IDE or use the todos tab in the IDE

You can also check the [Todo](./doc/todo.md) list or the issues if you want to

> Make sure to not edit the `CHANGELOG.md` or the version in `pubspec.yaml` for any of the packages, CI will automate
> this process.

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install), which can be installed by following the instructions the
  provided link, also make sure to add it to your path so `flutter --version` and `dart --version` work
- [IntelliJ IDEA Community Edition](https://www.jetbrains.com/idea/download/)
  or [Android Studio](https://developer.android.com/studio) (with Dart and Flutter plugins) or
  use [VS Code](https://code.visualstudio.com/) (with Dart and flutter extensions)

## Test your changes 🧪

Make sure you have the [Requirement](#requirements) installed and configured correctly

To test your changes:

1. Go to the [Example project](./example/) in [main.dart](./example/lib/main.dart) and run the project either by using
   your IDE or `flutter run`
2. Make sure to read the [Development Notes](./doc/development_notes.md) if you made certain changes
   or [Translations Page](./doc/translation.md) if you made changes to the translations of the package

## Steps to contributing

You will need a GitHub account as well as Git installed and configured with your GitHub account on your machine

1. Fork the repository in GitHub
2. clone the forked repository using `git`
3. Add the `upstream` repository using:
    ```
    git remote add upstream git@github.com:singerdmx/flutter-quill.git
    ```
4. Open the project with your favorite IDE, usually, we prefer to use Jetbrains IDEs, but
   since [VS Code](https://code.visualstudio.com) is more used and has more support for Dart, then we suggest using it
   if you want to.
5. Create a new git branch and switch to it using `git checkout -b`
6. Make your changes
7. If you are working on changes that depend on different libraries in the same repo, then in that directory
   copy `pubspec_overrides.yaml.disabled` which exists in all the packages (`flutter_quill_test`
   and `flutter_quill_extensions` etc...)
   to `pubspec_overrides.yaml` which will be ignored by `.gitignore` and will be used by dart pub to override the
   libraries
    ```
    cp pubspec_overrides.yaml.disabled pubspec_overrides.yaml
    ```
   or save some time with the following script:
    ```
    dart ./scripts/enable_local_dev.dart
    ```
8. Test them in the [example](./example) and add changes in there if necessary
9. Run the following script if possible
   ```shell
   dart ./scripts/before_push.dart
   ```
10. When you are done sending your pull request, run:
    ```
    git add .
    git commit -m "Your commit message"
    git push origin <your-branch-name>
    ```
    this will push the new branch to your forked repository

11. Now you can send your pull request either by following the link that you will get in the command line or open your
    forked repository. You will find an option to send the pull request, you can also
    open the [Pull Requests](https://github.com/singerdmx/flutter-quill) tab and send new pull request

12. Now, wait for the review, and we might ask you to make more changes, then run:

```
git add .
git commit -m "Your new commit message"
git push origin your-branch-name
```

Thank you for your time and efforts in open-source projects!!

## Guidelines 📝

<!-- TODO: Update the guidelines -->

1. **Code Style and Formatting**:

   Adhere to the Dart Coding Conventions (https://dart.dev/effective-dart).
   Use consistent naming conventions for variables, functions, classes, etc.
   Follow a consistent code formatting style throughout the project.

   We use [Dart lints](https://dart.dev/tools/linter-rules) to make the process easier.
2. **Documentation**:

   Document public APIs using Dart comments (https://dart.dev/effective-dart/documentation).
   Provide comprehensive documentation for any complex algorithms, data structures, or significant functionality.
   Write clear and concise commit messages and pull request descriptions.
3. **Performance**:

   Write efficient code and avoid unnecessary overhead.
   Profile the application for performance bottlenecks and optimize critical sections if needed.
4. **Bundle size**:

   Try to make the package size as less as possible but as much as needed
5. **Code Review**:

   Encourage code reviews for all changes to maintain code quality and catch potential issues early.
   Use pull requests and code reviews to discuss proposed changes and improvements.
6. **Versioning and Releases**:

   Try to follow semantic versioning for releases (https://semver.org/) when possible.
   Clearly document release notes and changes for each version.
   Please notice for now we might introduce breaking changes in non-major version but will always provide migration
   guide in each release info and in [Migration guide](./doc/migration.md)
7. **Consistency**:

   Adhere to a consistent coding style throughout the project for improves readability and maintainability
8. **Meaningful Names**:

   Use descriptive variable, class, and function names that clearly convey their purpose.
9. **Testing**:

   Try to write tests (Widget or Unit tests or other types or tests) when possible

## Development Notes

Please read the [Development Notes](./doc/development_notes.md) as they might be important while development