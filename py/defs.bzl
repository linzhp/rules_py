"Public API re-exports"

load("//py/private:py_binary.bzl", _py_binary = "py_binary", _py_test = "py_test")
load("//py/private:py_library.bzl", _py_library = "py_library")
load("//py/private:py_pytest_main.bzl", _py_pytest_main = "py_pytest_main")
load("//py/private:py_wheel.bzl", "py_wheel_lib")
load("//py/private/venv:venv.bzl", _py_venv = "py_venv")

def py_library(name, imports = ["."], **kwargs):
    """Wrapper macro for the py_library rule, setting a default for imports

    Args:
        name: name of the rule
        **kwargs: see [py_library attributes](./py_library)
    """
    _py_library(
        name = name,
        imports = imports,
        **kwargs
    )

def py_binary(name, srcs = [], main = None, imports = ["."], **kwargs):
    """Wrapper macro for the py_binary rule, setting a default for imports.

    It also creates a virtualenv to constrain the interpreter and packages used at runtime,
    you can `bazel run [name].venv` to produce this, then use it in the editor.

    Args:
        name: name of the rule
        srcs: python source files
        main: the entry point. If absent, then the first entry in srcs is used.
        **kwargs: see [py_binary attributes](./py_binary)
    """
    if not main and not len(srcs):
        fail("When 'main' is not specified, 'srcs' must be non-empty")
    _py_binary(
        name = name,
        srcs = srcs,
        main = main if main != None else srcs[0],
        imports = imports,
        **kwargs
    )

    _py_venv(
        name = "%s.venv" % name,
        deps = kwargs.pop("deps", []),
        imports = imports,
        srcs = srcs,
        tags = ["manual"],
    )

def py_test(name, main = None, srcs = [], imports = ["."], **kwargs):
    "Identical to py_binary, but produces a target that can be used with `bazel test`."
    _py_test(
        name = name,
        srcs = srcs,
        main = main if main != None else srcs[0],
        imports = imports,
        **kwargs
    )

    _py_venv(
        name = "%s.venv" % name,
        deps = kwargs.pop("deps", []),
        imports = imports,
        srcs = srcs,
        tags = ["manual"],
    )

py_wheel = rule(
    implementation = py_wheel_lib.implementation,
    attrs = py_wheel_lib.attrs,
    provides = py_wheel_lib.provides,
)

py_pytest_main = _py_pytest_main
