;================================================================================;
;
;   Tachyon SDK for Mojo
;
;   Copyright (C) 2026 Annhilati
;
;   Description: LLVM IR Transport Layer (Translates Pointers to Values)
;
;================================================================================;

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024"
target triple = "spir64-unknown-unknown"

declare spir_func <4 x float> @tachyon_main(<4 x float>, float)
define spir_func <4 x float> @tachyon_main_ptr(<4 x float>* %color, float* %time) {
entry:
  %c = load <4 x float>, <4 x float>* %color
  %t = load float, float* %time
  %res = call spir_func <4 x float> @tachyon_main(<4 x float> %c, float %t)
  ret <4 x float> %res
}
