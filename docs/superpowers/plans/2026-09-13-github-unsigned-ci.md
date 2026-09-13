# GitHub Unsigned iOS CI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Compile every V14 iOS target with a real macOS/Xcode runner and publish an unsigned IPA plus complete diagnostic logs.

**Architecture:** A single GitHub Actions workflow installs XcodeGen, runs Swift Package tests, generates the Xcode project, compiles all five schemes for the simulator, then builds the host app for the device SDK without signing. A repository script owns the build commands and writes stable log files so local Mac runs and GitHub runs behave identically.

**Tech Stack:** Swift Package Manager, XcodeGen, xcodebuild, GitHub Actions, macOS hosted runner.

## Global Constraints

- Use `WeTypeReplicaOverlay_v14.zip` as the only source baseline.
- Build without Apple certificates or provisioning profiles.
- Compile Host App, Keyboard Extension, Share Extension, Widget, and Voice Activity.
- Upload complete logs on success and failure.
- Package the unsigned device `.app` as an `.ipa` artifact.

---

### Task 1: Reproducible unsigned build entry point

**Files:**
- Create: `Tools/verify_ci_configuration.py`
- Create: `XcodeIntegration/ci_unsigned_build.sh`
- Modify: `XcodeIntegration/validate_on_mac.sh`

**Interfaces:**
- Consumes: `Package.swift` and `XcodeIntegration/project.yml`.
- Produces: `artifacts/logs/*.log`, `artifacts/unsigned/Payload/WeTypeReplicaApp.app`, and `artifacts/WeTypeReplicaApp-unsigned.ipa`.

- [ ] **Step 1: Write the failing CI configuration verifier**
- [ ] **Step 2: Run it and confirm the missing workflow/build script failure**
- [ ] **Step 3: Add the minimal unsigned build script and include all five schemes**
- [ ] **Step 4: Run the verifier and existing pre-CI checks**

### Task 2: GitHub Actions workflow

**Files:**
- Create: `.github/workflows/ios-unsigned-ci.yml`

**Interfaces:**
- Consumes: `XcodeIntegration/ci_unsigned_build.sh`.
- Produces: GitHub Actions log and IPA artifacts.

- [ ] **Step 1: Add manual and push triggers on a macOS runner**
- [ ] **Step 2: Install XcodeGen and execute the repository build script**
- [ ] **Step 3: Upload logs unconditionally and the unsigned IPA on success**
- [ ] **Step 4: Validate workflow structure locally**

### Task 3: Run and repair real Xcode CI

**Files:**
- Modify: only files implicated by captured compiler errors.
- Create: `CI_FIX_LOG.md`

**Interfaces:**
- Consumes: GitHub Actions compiler diagnostics.
- Produces: a green workflow run and a chronological root-cause/fix record.

- [ ] **Step 1: Initialize and push the repository**
- [ ] **Step 2: Trigger the unsigned workflow and download full logs**
- [ ] **Step 3: For each failure, record the exact error and root cause before changing code**
- [ ] **Step 4: Apply one focused fix and rerun the relevant gate**
- [ ] **Step 5: Repeat until all five schemes and device packaging pass**
- [ ] **Step 6: Download the final IPA and CI logs into `outputs/`**

