load(
    "@com_github_mvukov_rules_ros2//ros2:interfaces.bzl",
    "ros2_interface_library",
    "cpp_ros2_interface_library",
    "py_ros2_interface_library",
)

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@com_github_mvukov_rules_ros2//ros2:service.bzl", "ros2_service")
load("@com_github_mvukov_rules_ros2//ros2:topic.bzl", "ros2_topic")

# These macros are meant to be what messages use for defining targets as opposed to using ros2_interface_library,
# etc.. This create a nice choke-point for us so that we can set settings for all msgs very easily.

def ros2_interface_agg(
    *,
    name,
    srcs,
    **kwargs
):
    has_messages = any([paths.split_extension(src)[1] == ".msg" for src in srcs])
    has_services = any([paths.split_extension(src)[1] == ".srv" for src in srcs])

    ros2_interface_library(name=name, srcs=srcs, **kwargs)
    cpp_ros2_interface_library(name="cpp_"+name, deps=[":"+name], visibility=["//visibility:public"])
    py_ros2_interface_library(name="py_"+name, deps=[":"+name], visibility=["//visibility:public"])

    if has_services:
        ros2_service(name="ros2service_"+name, deps=[":py_"+name], visibility=["//visibility:public"])

    if has_messages:
        ros2_topic(name="ros2topic_"+name, deps=[":py_"+name], visibility=["//visibility:public"])
        
        native.filegroup(
            name = "{}_msgs_filegroup".format(name),
            srcs = native.glob([src for src in srcs if paths.split_extension(src)[1] == ".msg"]),
            visibility = ["//visibility:public"]
        )