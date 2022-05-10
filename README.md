# Format and Lint in Xcode

_For Swift source code._

This project shows multiple options for integrating automatic code formatting, additional linting and code clean up. 

## The moving parts

- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
	- (_Not_ to be confused with [this](https://github.com/apple/swift-format))
	- Can also be used for linting. 
- [SwiftLint](https://github.com/realm/SwiftLint)
- Xcode _Build Phases_
- Git pre-commit _hook_
	- To "install": `cp Config/pre-commit .git/hooks && chmod +x .git/hooks/pre-commit`

## Pros

- Cleaner code automatically. 
- Project/team consistency for files. 
- Better/additional feedback from static analysis. 
- **It's 2022, and Select-and-Indent doesn't cut it anymore!**

## Cons

- Since Xcode only likes to update analysis/warnings on build, we often hit `Cmd-b` often, which can make the code change out from under you if it is invoked frequently (such as on the main target's Build Phase).
- At times, Xcode can be finicky about files that change on-disk. 
- Breakpoints can "move" as lines change from refactoring. 

## Notes

- Git GUIs and Xcode Build Phases often don't have access to the entire Shell/terminal environment's `PATH`. 
    - So, we have to amend the `PATH` manually for those (in the phase scripts and/or git hooks).
- Most places suggestion using `SDKTOOR=macosx` for the package-style invocation, but then you get a warning in the build log.
	- So, we make it dynamic here. 
- Don't forget having a `.swift-version` file to silence other warnings. 

## Possible future additions

- Add screen shots for set up.
- Add an _xcconfig_ for warnings?
- Same stuff for ObjC source?
- More about configuring _SwiftFormat_ and _SwiftLint_?
- Field debugging with `build_versioning.sh`? (see branch)
- Build number automation with git commit count (Xcode changed?) and/or agvtool?

