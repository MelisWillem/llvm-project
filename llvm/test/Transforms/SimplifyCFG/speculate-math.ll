; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 < %s | FileCheck %s
; RUN: opt -S -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -speculate-one-expensive-inst=false < %s | FileCheck %s

declare float @llvm.sqrt.f32(float) nounwind readonly
declare float @llvm.fma.f32(float, float, float) nounwind readonly
declare float @llvm.fmuladd.f32(float, float, float) nounwind readonly
declare float @llvm.fabs.f32(float) nounwind readonly
declare float @llvm.minnum.f32(float, float) nounwind readonly
declare float @llvm.maxnum.f32(float, float) nounwind readonly
declare float @llvm.minimum.f32(float, float) nounwind readonly
declare float @llvm.maximum.f32(float, float) nounwind readonly

define double @fdiv_test(double %a, double %b) {
; CHECK-LABEL: @fdiv_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt double [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[B:%.*]], [[A]]
; CHECK-NEXT:    [[COND:%.*]] = select nsz i1 [[CMP]], double [[DIV]], double 0.000000e+00
; CHECK-NEXT:    ret double [[COND]]
;
entry:
  %cmp = fcmp ogt double %a, 0.0
  br i1 %cmp, label %cond.true, label %cond.end

cond.true:
  %div = fdiv double %b, %a
  br label %cond.end

cond.end:
  %cond = phi nsz double [ %div, %cond.true ], [ 0.0, %entry ]
  ret double %cond
}

define void @sqrt_test(ptr addrspace(1) noalias nocapture %out, float %a) nounwind {
; CHECK-LABEL: @sqrt_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.sqrt.f32(float [[A]]) #[[ATTR2:[0-9]+]]
; CHECK-NEXT:    [[COND_I:%.*]] = select afn i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_sqrt.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.sqrt.f32(float %a) nounwind readnone
  br label %test_sqrt.exit

test_sqrt.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi afn float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @fabs_test(ptr addrspace(1) noalias nocapture %out, float %a) nounwind {
; CHECK-LABEL: @fabs_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fabs.f32(float [[A]]) #[[ATTR2]]
; CHECK-NEXT:    [[COND_I:%.*]] = select reassoc i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_fabs.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.fabs.f32(float %a) nounwind readnone
  br label %test_fabs.exit

test_fabs.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi reassoc float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @fma_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b, float %c) nounwind {
; CHECK-LABEL: @fma_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fma.f32(float [[A]], float [[B:%.*]], float [[C:%.*]]) #[[ATTR2]]
; CHECK-NEXT:    [[COND_I:%.*]] = select reassoc nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_fma.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.fma.f32(float %a, float %b, float %c) nounwind readnone
  br label %test_fma.exit

test_fma.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi nsz reassoc float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @fmuladd_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b, float %c) nounwind {
; CHECK-LABEL: @fmuladd_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fmuladd.f32(float [[A]], float [[B:%.*]], float [[C:%.*]]) #[[ATTR2]]
; CHECK-NEXT:    [[COND_I:%.*]] = select ninf i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_fmuladd.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.fmuladd.f32(float %a, float %b, float %c) nounwind readnone
  br label %test_fmuladd.exit

test_fmuladd.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi ninf float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @minnum_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b) nounwind {
; CHECK-LABEL: @minnum_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.minnum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-NEXT:    [[COND_I:%.*]] = select i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_minnum.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.minnum.f32(float %a, float %b) nounwind readnone
  br label %test_minnum.exit

test_minnum.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @maxnum_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b) nounwind {
; CHECK-LABEL: @maxnum_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.maxnum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-NEXT:    [[COND_I:%.*]] = select ninf nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_maxnum.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.maxnum.f32(float %a, float %b) nounwind readnone
  br label %test_maxnum.exit

test_maxnum.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi ninf nsz float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @minimum_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b) nounwind {
; CHECK-LABEL: @minimum_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.minimum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-NEXT:    [[COND_I:%.*]] = select reassoc i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_minimum.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.minimum.f32(float %a, float %b) nounwind readnone
  br label %test_minimum.exit

test_minimum.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi reassoc float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @maximum_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b) nounwind {
; CHECK-LABEL: @maximum_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = tail call float @llvm.maximum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-NEXT:    [[COND_I:%.*]] = select nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_maximum.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.maximum.f32(float %a, float %b) nounwind readnone
  br label %test_maximum.exit

test_maximum.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi nsz float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}
