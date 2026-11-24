# Recomp Achievements SDK (vendored)

Upstream: https://github.com/elripalda/RecompAchievements
Revision: `faf094a` ("Spec: PS3 (ps3) native and events lists, and developers can keep their list from the developer hub")
rcheevos: as bundled upstream (`sdk/third_party/rcheevos/VERSION`)

Only what the upstream `sdk/CMakeLists.txt` compiles is kept: `sdk/include`,
`sdk/src`, cJSON, and rcheevos `include` plus `src/runtime` and `src/util`.
The tests, bridges and examples are left out. Files are unmodified.

Licenses: `LICENSE` (Recomp Achievements License 1.0: free for any game; keep
this license and the copyright notice with the source), `sdk/third_party/cjson/LICENSE`
(MIT), `sdk/third_party/rcheevos/LICENSE` (MIT).

Used by `ports/mercenaries/src/recomp_launcher_channel.c` to talk to
RecompLauncher over the `RL_SESSION` channel. Without RecompLauncher every
call returns immediately.

| File | SHA-256 |
| --- | --- |
| `LICENSE` | `476c321f3eb9b76f0fcdffbe7132b1afc0949a72f98b43422e7fecd0a09a5c1f` |
| `sdk/include/rl_achievements.h` | `1dea96c04cea8f80cf2f8dd1249c4bb50ca6b07e943fbf7a8fef0fc3d91a898d` |
| `sdk/src/rl_achievements.c` | `918fe5ffe4adcbff27211a892b661654a559732f4e7df2b414191ee87439a2d4` |
| `sdk/third_party/cjson/cJSON.c` | `607e756460fa0de37d20a7a9181f2de29c97bfb7ce5a0e6c2f548243836cd852` |
| `sdk/third_party/cjson/cJSON.h` | `25b0145150d500498e4d209cec69c18c42cf818bffcc54690be3b895a2a16dee` |
| `sdk/third_party/cjson/LICENSE` | `a36dda207c36db5818729c54e7ad4e8b0c6fba847491ba64f372c1a2037b6d5c` |
| `sdk/third_party/rcheevos/include/module.modulemap` | `34c639d6d41252c49a6fdbf298669b7826baeac3412770ccdf967d12cd235f70` |
| `sdk/third_party/rcheevos/include/rc_api_editor.h` | `fee5ef463ec2595a71a5bfb325a798153877f885c9cad1de6ee1891a521139a1` |
| `sdk/third_party/rcheevos/include/rc_api_info.h` | `5c553b7dd109e854b3d3bfbecb9fb69b56cf922c25f88d04d9fe9bb162410f2a` |
| `sdk/third_party/rcheevos/include/rc_api_request.h` | `2d27109deb502ed447cb821815a04c30bec37b90b1016f805960efc056a2d9bc` |
| `sdk/third_party/rcheevos/include/rc_api_runtime.h` | `34d22b460b8ac02c9d66d5f6e14020d815d00954a811ba9ae41c0d3a0c05a8ab` |
| `sdk/third_party/rcheevos/include/rc_api_user.h` | `bdb866fe0a865eea2697fda384c724e42bb496a417104d8654aab45f9b3a5c67` |
| `sdk/third_party/rcheevos/include/rc_client.h` | `debe8bdaaabe767929f4bdae25f6e93e816ca3030363b22097f79e6bb69c07fa` |
| `sdk/third_party/rcheevos/include/rc_client_callbacks.h` | `9c87c09a9b0ef8dd3575d9d13b6b10ce4d9073f49addad4cad04000f8db8ef6a` |
| `sdk/third_party/rcheevos/include/rc_client_raintegration.h` | `8b4f9eaa7b16f024e5616cc32aecad7bb6be69bdf011a95ea63871c872509d91` |
| `sdk/third_party/rcheevos/include/rc_consoles.h` | `73c1178e501692a11fb702eb1d90d25a7c47ed1d02678c619bc087c9755b132b` |
| `sdk/third_party/rcheevos/include/rc_error.h` | `b8d8214fe7ed4c0bb86420f1bfc4c4cb63548907b2c1001fea2083a55554763a` |
| `sdk/third_party/rcheevos/include/rc_export.h` | `9683f979bb152781677ffd952a68fdddcb5d951eb227e96a2d1f7fd0feb3be62` |
| `sdk/third_party/rcheevos/include/rc_hash.h` | `b2eeb7eb928ed07094463eefd8111ecc69a2f8aeb04e63b23172dcf3663a271b` |
| `sdk/third_party/rcheevos/include/rc_runtime.h` | `d10863351b73cbfac8de324571075297654062dad126d677c81cc1d717d0a994` |
| `sdk/third_party/rcheevos/include/rc_util.h` | `12840744dcca64ffd2e5f0a1c92fca2e235236edd5a66d8787d1d26189254344` |
| `sdk/third_party/rcheevos/include/rcheevos.h` | `793d0d3a84d0f91507cfd606e0d69b4bcf431db0c3f8c3416a8473c76e54b3a7` |
| `sdk/third_party/rcheevos/LICENSE` | `bf820c034966a3b6be050bb85f94ec841a0b972bd5d477e362337d0574b5c219` |
| `sdk/third_party/rcheevos/src/runtime/rc_alloc.c` | `af007681af7e05593a4daffb403d77f59022ebcac2fb8f5fb38649c5a562b559` |
| `sdk/third_party/rcheevos/src/runtime/rc_alloc.h` | `3ed6e731c5d911d83d51cda00a5de8a79b78830cbef4728eef40b713c7a1e0e1` |
| `sdk/third_party/rcheevos/src/runtime/rc_condition.c` | `0a63b7ab9a6e179f44ccced31284e9c2f890cc30a06b3f27019296d992a9a309` |
| `sdk/third_party/rcheevos/src/runtime/rc_condition.h` | `f7ee5424423fa1251b0dbe3a9cf9e62cacb9f8e19b089dd5dce312e0e3f0bad8` |
| `sdk/third_party/rcheevos/src/runtime/rc_condset.c` | `2623a61792d2c44fcc7f8b464bdee8a64dd93e672edb6334b9366a1a01b745ce` |
| `sdk/third_party/rcheevos/src/runtime/rc_condset.h` | `97daa9c79bb3b1a3f5999982335f1a9c9eb6a59f5a3eac3e9afaa1ef2920cf3c` |
| `sdk/third_party/rcheevos/src/runtime/rc_consoleinfo.c` | `ea191584518488a3b9ecb6f663c3924a57cf8e816387b0deac493c9c005ea5a9` |
| `sdk/third_party/rcheevos/src/runtime/rc_eval_state.h` | `153db30809da34f587fbb02018dcaa87453cfabb0d170ee13aaf0538fb5fda75` |
| `sdk/third_party/rcheevos/src/runtime/rc_format.c` | `8458dc2a0e555420646bf2f80f10277f949a17917628af4c921f920f0c87f769` |
| `sdk/third_party/rcheevos/src/runtime/rc_format.h` | `9ab273596d7c1e93559274c68d7d694346a31f16e916f934b62687b2511ea61f` |
| `sdk/third_party/rcheevos/src/runtime/rc_lboard.c` | `f93480541b8292e6a965d23bcf148a75dbf386da45562f8848c2dbf23e93cb40` |
| `sdk/third_party/rcheevos/src/runtime/rc_lboard.h` | `9be96b45ad291ca4ba18e843fdd4b7dc3620ad5cdf04db975bcddc82b3a8b840` |
| `sdk/third_party/rcheevos/src/runtime/rc_memref.c` | `818555a31d16f956007bb1c6e9ba784a16381541451943ee4395adc7fd377baa` |
| `sdk/third_party/rcheevos/src/runtime/rc_memref.h` | `dc1635a8025507eac68cbb63791471c070781cb173c0896b037d3745c8c2a82c` |
| `sdk/third_party/rcheevos/src/runtime/rc_modified_memref.h` | `4f1de1226041060fd7ae32d89dd701c36e7151f25781233edbf11a40214e45b3` |
| `sdk/third_party/rcheevos/src/runtime/rc_operand.c` | `574aa0e44c6ce363e9d2724d89cf8f9429839b056f51321253a0eeebf0bba8d6` |
| `sdk/third_party/rcheevos/src/runtime/rc_operand.h` | `1707259c0c9e9d09a3b8466ad3fd55373591dd57e5a95ff3cc151a38995dc2ca` |
| `sdk/third_party/rcheevos/src/runtime/rc_operator.h` | `9601518d53b7649daef827c256f247f3867b06015d67c2398a88f16c7e8b1333` |
| `sdk/third_party/rcheevos/src/runtime/rc_parse_state.h` | `0345416698347d1e450a9060c2124375d9e533cbd1e9093b849bb7f3c85f7956` |
| `sdk/third_party/rcheevos/src/runtime/rc_richpresence.c` | `7a5bd76e1f93a2428f3edc34802e639f2a60917422d1400f6b3d427e41479f9f` |
| `sdk/third_party/rcheevos/src/runtime/rc_richpresence.h` | `8e7e094c0fa6a96b877a51e295300e31efae8253aa2a28232689eb05e29b863a` |
| `sdk/third_party/rcheevos/src/runtime/rc_runtime.c` | `93b1ae3b3a7af3faef66d1c919896d5ed3c8db90a4637f832c4590a657f925a6` |
| `sdk/third_party/rcheevos/src/runtime/rc_runtime_progress.c` | `4f1b82b7ff5f42a1d5f50dfa41e5f9ecee42817368535601c8e4b812a6721229` |
| `sdk/third_party/rcheevos/src/runtime/rc_trigger.c` | `9836cc5701b1eb536a7d2c1ef9b50f63c249dfabbf1f6849ed60272c4c2aa832` |
| `sdk/third_party/rcheevos/src/runtime/rc_trigger.h` | `d23a48d73879c23cfc8807768909c9c453e27a65a4fa07ed75ddc9b980500b84` |
| `sdk/third_party/rcheevos/src/runtime/rc_typed_value.c` | `21829bff83b799781bddbc06ac8bc78914b5600151f34c95b4909005ede43083` |
| `sdk/third_party/rcheevos/src/runtime/rc_typed_value.h` | `7b7b86406af72bc2cd834a3fa2e91e971d728430327aa41dabcfb777fffb14ef` |
| `sdk/third_party/rcheevos/src/runtime/rc_validate.c` | `9280284a494e8b37515124eb819a64185287818f08a933dee3b6db516388a6c0` |
| `sdk/third_party/rcheevos/src/runtime/rc_validate.h` | `f1b84f301bc326da292461276768857af497d91df5ba9fb243ff55b8d063b4b1` |
| `sdk/third_party/rcheevos/src/runtime/rc_value.c` | `344157dfededc75131afba5a5781996d03ab8eae03bc1ade82aab280f3b95033` |
| `sdk/third_party/rcheevos/src/runtime/rc_value.h` | `a34ed5d955b6b284773c45b95be8b264712853f3a82b6104a3713e8cfca2d1c4` |
| `sdk/third_party/rcheevos/src/util/md5.c` | `fd38ee6a43316007d4aa816f23c24a8355c58df106b4c54e43ec44afc55df521` |
| `sdk/third_party/rcheevos/src/util/md5.h` | `8341e2a307d7cfaeb816b261d92ce87a07be62e3eb58c98d2c769e75a6e2b959` |
| `sdk/third_party/rcheevos/src/util/rc_compat.c` | `0ff1eb764859e63ac1e3376265b5cb9a31d5bc33db35beb7d9f9667473ef04c8` |
| `sdk/third_party/rcheevos/src/util/rc_compat.h` | `fd0f4e98a30ad80d5c44514302036fd8072f13479b3e2e00d4f31f875f1c04b6` |
| `sdk/third_party/rcheevos/src/util/rc_util.c` | `8e7a44443c9062054ee97bb9c60148ea7f14116a42d525d8abe3835a0a5c9666` |
| `sdk/third_party/rcheevos/src/util/rc_version.c` | `210091300446cf20bcbfc8f80c747c543a5a99e143887cf6aff16ab5f5a245a3` |
| `sdk/third_party/rcheevos/src/util/rc_version.h` | `99db64703fd642b32812efe3b6fefb4843a2f1da6352aed3cb0d89cefcaafe0d` |
| `sdk/third_party/rcheevos/VERSION` | `e119015d52392d617fddc0c9550cf72709eefd561a21dbd4cd7975ec9f47f988` |
