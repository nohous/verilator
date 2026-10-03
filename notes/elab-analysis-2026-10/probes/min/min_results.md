| probe | rc | first diagnostic |
|---|---|---|
| c1_selftype | 1 | Recursive type definition |
| c2_selfvalue | 1 | Variable's initial value is circular: 'A' |
| c3_nestedvalue | 139 | SEGFAULT (dotted expressions in parameters) |
| d10_struct_proj_direct | 0 | ok |
| d11_both_chains_in_one_module | 0 | ok |
| d1_proj_default_1level | 0 | ok |
| d2_proj_default_3level | 0 | ok |
| d3_proj_default_explicit_I0 | 0 | ok |
| d4_proj_default_as_member | 0 | ok |
| d5_typedef_alias_of_projection | 0 | ok |
| d6_typedef_alias_plain_class_proj | 0 | ok |
| d7_two_aliases_same_default | 0 | ok |
| d8_struct_proj_chain_2 | 0 | ok |
| d9_struct_proj_chain_1 | 0 | ok |
| deep_12 | 0 | ok |
| deep_16 | 0 | ok |
| deep_24 | 0 | ok |
| deep_4 | 0 | ok |
| deep_40 | 0 | ok |
| deep_8 | 0 | ok |
| deep_80 | 0 | ok |
| e1_extends_dependent_base | 1 | Class parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T' |
| e2_extends_dependent_base_default_T | 0 | ok |
| e3_no_extends_dependent_type | 1 | Class parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T' |
| e4_extends_explicit_both | 0 | ok |
| e5_named_pin_dependent_default | 1 | Class parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T' |
| e6_positional_both_defaults | 1 | Recursive type definition |
| e7_positional_nodefault_simple_dep | 0 | ok |
| e8_positional_value_then_dep_type | 1 | Expecting expression to be constant, but variable isn't const: 'N' |
| e9_named_value_then_dep_type | 1 | Expecting expression to be constant, but variable isn't const: 'N' |
| m10_T_proj_plus_width_N | 0 | ok |
| m11_body_bits_of_T_ok | 139 | SEGFAULT (Verilator internal fault, sorry. Suggest trying --debug --gdbbt) |
| m1_full_chain | 139 | SEGFAULT (Verilator internal fault, sorry. Suggest trying --debug --gdbbt) |
| m2_no_U_no_N | 0 | ok |
| m3_T_from_W_direct | 0 | ok |
| m4_T_const_pin | 0 | ok |
| m5_full_chain_defaults_only | 139 | SEGFAULT (Verilator internal fault, sorry. Suggest trying --debug --gdbbt) |
| m6_D_chain_no_class | 0 | ok |
| m7_class_pin_is_param_only | 0 | ok |
| m8_T_proj_plus_alias_U | 0 | ok |
| m9_T_proj_plus_bits_N | 139 | SEGFAULT (Verilator internal fault, sorry. Suggest trying --debug --gdbbt) |
| v1_module_lparam_from_class | 0 | ok |
| v2_module_param_default | 0 | ok |
| v3_class_param_default | 139 | SEGFAULT (dotted expressions in parameters) |
| v4_class_param_default_dep | 139 | SEGFAULT (dotted expressions in parameters) |
| v5_type_then_value_proj | 1 | dotted expressions in parameters |
