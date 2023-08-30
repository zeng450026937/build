# -*- bazel-starlark -*-
# Copyright 2023 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""Siso configuration for linux."""

load("@builtin//struct.star", "module")
load("./clang_linux.star", "clang")
load("./config.star", "config")
load("./mojo.star", "mojo")
load("./nacl_linux.star", "nacl")
load("./nasm_linux.star", "nasm")
load("./proto_linux.star", "proto")
load("./reproxy.star", "reproxy")
load("./android.star", "android")

__filegroups = {}
__filegroups.update(android.filegroups)
__filegroups.update(clang.filegroups)
__filegroups.update(mojo.filegroups)
__filegroups.update(nacl.filegroups)
__filegroups.update(nasm.filegroups)
__filegroups.update(proto.filegroups)

__handlers = {}
__handlers.update(android.handlers)
__handlers.update(clang.handlers)
__handlers.update(mojo.handlers)
__handlers.update(nacl.handlers)
__handlers.update(nasm.handlers)
__handlers.update(proto.handlers)

def __disable_remote_b289968566(ctx, step_config):
    rule = {
        # TODO(b/289968566): they often faile with exit=137 (OOM?).
        # We should migrate default machine type to n2-standard-2.
        "name": "b289968566/exit-137",
        "action_outs": [
            "./android_clang_arm/obj/third_party/distributed_point_functions/distributed_point_functions/evaluate_prg_hwy.o",
            "./clang_x64_v8_arm64/obj/v8/torque_generated_initializers/js-to-wasm-tq-csa.o",
            "./clang_x64_v8_arm64/obj/v8/torque_generated_initializers/wasm-to-js-tq-csa.o",
            "./clang_x86_v8_arm/obj/v8/torque_generated_initializers/js-to-wasm-tq-csa.o",
            "./clang_x86_v8_arm/obj/v8/torque_generated_initializers/wasm-to-js-tq-csa.o",
            "./obj/chrome/browser/ash/ash/autotest_private_api.o",
            "./obj/chrome/browser/ash/ash/chrome_browser_main_parts_ash.o",
            "./obj/chrome/browser/browser/browser_prefs.o",
            "./obj/chrome/browser/browser/chrome_browser_interface_binders.o",
            "./obj/chrome/browser/ui/ash/holding_space/browser_tests/holding_space_ui_browsertest.o",
            "./obj/chrome/test/browser_tests/browser_non_client_frame_view_chromeos_browsertest.o",
            "./obj/chrome/test/browser_tests/chrome_shelf_controller_browsertest.o",
            "./obj/chrome/test/browser_tests/device_local_account_browsertest.o",
            "./obj/chrome/test/browser_tests/file_manager_browsertest_base.o",
            "./obj/chrome/test/browser_tests/remote_apps_manager_browsertest.o",
            "./obj/v8/torque_generated_initializers/js-to-wasm-tq-csa.o",
            "./obj/v8/torque_generated_initializers/wasm-to-js-tq-csa.o",
        ],
        "remote": False,
    }
    if reproxy.enabled(ctx):
        rule["handler"] = "strip_rewrapper"
    step_config["rules"].insert(0, rule)
    return step_config

def __step_config(ctx, step_config):
    config.check(ctx)
    step_config["platforms"].update({
        "default": {
            "OSFamily": "Linux",
            "container-image": "docker://gcr.io/chops-public-images-prod/rbe/siso-chromium/linux@sha256:912808c295e578ccde53b0685bcd0d56c15d7a03e819dcce70694bfe3fdab35e",
            "label:action_default": "1",
        },
    })

    step_config = __disable_remote_b289968566(ctx, step_config)

    if android.enabled(ctx):
        step_config = android.step_config(ctx, step_config)

    step_config = nacl.step_config(ctx, step_config)
    step_config = nasm.step_config(ctx, step_config)
    step_config = proto.step_config(ctx, step_config)
    step_config = mojo.step_config(ctx, step_config)
    step_config = clang.step_config(ctx, step_config)

    return step_config

chromium = module(
    "chromium",
    step_config = __step_config,
    filegroups = __filegroups,
    handlers = __handlers,
)
