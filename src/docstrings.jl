## Docstring Templates

using DocStringExtensions

@template (FUNCTIONS, METHODS, MACROS) = """
                                         $(TYPEDSIGNATURES)

                                         $(DOCSTRING)
                                         """

@template TYPES = """
                $(TYPEDEF)

                $(DOCSTRING)
                """
