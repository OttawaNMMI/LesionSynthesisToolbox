% 
% /* adapted from IDL
% original code found at https://groups.google.com/forum/#!topic/comp.lang.idl-pvwave/rClVssCaGww
% ;+
% ; NAME:
% ;   SPLINECOEFF
% ;
% ; PURPOSE:
% ;   This procedure computes coefficients of cubic splines
% ;   for a given observational set and smoothing parameter
% ;   lambda. The method is coded according to Pollock D.S.G.
% ;   (1999), "A Handbook of Time-Series Analysis, Signal
% ;   Processing and Dynamics, Academic Press", San Diego
% ;
% ; CATEGORY:
% ;   Data processing
% ;
% ; CALLING SEQUENCE:
% ;   COEFFS = SPLINECOEFF([X,] Y, [SIGMA], LAMBDA=LAMBDA)
% ;
% ; INPUTS:
% ;   X     = 1D Array (independent variable)
% ;   Y     = 1D Array (function)
% ;   SIGMA = 1D Array (weight of each measurement) By default
% ;           all the measurements are of the same weight.
% ;
% ; KEYWORDS:
% ;   LAMBDA = Smoothing parameter (It can be determined
% ;            empiricali, by the LS method or by cross-
% ;            validation, eg. see book of Pollock.) LAMBDA
% ;            equals 0 results in a cubic spline interpolation.
% ;            In the other extreme, for a very large LAMBDA
% ;            the result is smoothing by a linear function.
% ;
% ; COMMENT:
% ;
% ; EXAMPLE:
% ;   X = .....
% ;   Y = .....
% ;   Coeffs = SPLINECOEFF(X, Y, LAMBDA = 1.d5)
% ;   Y1 = N_ELEMENTS(Y) - 1
% ;   X1 = X(0:N_ELEMENTS(Y)-2)
% ;   FOR i = 0, N_ELEMENTS(Y)-2 DO Y1(i) = Coeff.D(I) + $
% ;                                           Coeff.C(I) * (X(I+1)-X(I)) + $
% ;                                               Coeff.B(I) * (X(I+1)-X(I))^2 + $
% ;                                               Coeff.A(I) * (X(I+1)-X(I))^3
% ;   PLOT, X, Y, PSYM = 3
% ;   OPLOT, X1, Y1
% ;
% ; OUTPUTS:
% ;   COEFFS: Structure of 4 arrays (A, B, C & D) containing
% ;           the coefficients of a spline between each two of
% ;           the given measurements.
% ;
% ; MODIFICATION HISTORY:
% ;   Written by: NV (Jan2006)
% ;               # as a function, NV (Mar2007)
% ;-
% */
