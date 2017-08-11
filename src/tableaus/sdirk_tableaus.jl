struct ESDIRK4Tableau{T,T2}
    γ::T
    a31::T
    a32::T
    a41::T
    a42::T
    a43::T
    bhat1::T
    bhat2::T
    bhat3::T
    bhat4::T
    c3::T2
    α31::T
    α32::T
    α41::T
    α42::T
end

#=
Derivative of Hermite Polynomial
k[1] + Θ*(-4*dt*k[1] - 2*dt*k[2] - 6*y₀ + Θ*(3*dt*k[1] + 3*dt*k[2] + 6*y₀ - 6*y₁) + 6*y₁)/dt

Extrapolation for ESDIRK interior step 3
dt = c2 since interval is [c1,c2] and c1 = 0
θ =  c3/c2 the extrapolation point
z = dt*k

z₁ + Θ*(-4dt*z₁ - 2dt*z₂ - 6y₀ + Θ*(3dt*z₁ + 3z₂ + 6y₀ - 6y₁ ) + 6y₁)/dt

Test Expression on TRBDF2:
c2 = 2 - sqrt(2)
c3 = 1
θ = c3/c2; dt = c2

Coefficient on z₁:
(1 + (-4θ + 3θ^2))*z₁
1 + (-4θ + 3θ^2) - (1.5 + sqrt(2)) # 1.5 + sqrt(2) given by Shampine

Coefficient on z₂:
(-2θ + 3θ^2)*z₂
(-2θ + 3θ^2) - (2.5 + 2sqrt(2)) # 2.5 + 2sqrt(2) given by Shampine

Coefficient on y₁-y₀:
θ*(θ*6(y₀-y₁)+6(y₁-y₀))/dt
θ*(-6θ(y₁-y₀)+6(y₁-y₀))/dt
(y₁-y₀)6θ*(1-θ)/dt

(6θ*(1-θ)/dt)*(y₁-y₀)

6θ*(1-θ)/dt - (- (6 + 4.5sqrt(2)))  # - (6 + 4.5sqrt(2)) given by Shampine

# Write only in terms of z primatives
y₀ = uprev
y₁ = uprev + γ*z₁ + γ*z₂
y₁-y₀ = γ*z₁ + γ*z₂

# Full Expression
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/dt)*γ)*z₁ + ((-2θ + 3θ^2) + (6θ*(1-θ)/dt)*γ)*z₂
=#

#=
# Kvaerno3
# Predict z4 from yhat

yhat = uprev + a31*z1 + a32*z2 + γ*z3
z₄ = yhat - uprev = a31*z1 + a32*z2 + γ*z3

# Note Hermite is too small of an interval for this one!!!
=#

function Kvaerno3Tableau(T,T2)
  γ   = T(0.4358665215)
  a31 = T(0.490563388419108)
  a32 = T(0.073570090080892)
  a41 = T(0.308809969973036)
  a42 = T(1.490563388254106)
  a43 = -T(1.235239879727145)
  bhat1 = T(0.490563388419108)
  bhat2 = T(0.073570090080892)
  bhat3 = T(0.4358665215)
  bhat4 = T(0.0)
  c3 = T2(1)
  c2 = 2γ
  θ = c3/c2
  α31 = ((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
  α32 = ((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)
  α41 = T(0.0)
  α42 = T(0.0)
  ESDIRK4Tableau(γ,a31,a32,a41,a42,a43,bhat1,bhat2,bhat3,bhat4,c3,α31,α32,α41,α42)
end

#=
# KenCarp3
# Predict z4 from Hermite z2 and z1
# Not z3 because c3 < c2 !

θ = c3/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)
θ = c4/c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)
=#

function KenCarp3Tableau(T,T2)
  γ  = T(1767732205903//4055673282236)
  a31 = T(2746238789719//10658868560708)
  a32 = -T(640167445237//6845629431997)
  a41 = T(1471266399579//7840856788654)
  a42 = -T(4482444167858//7529755066697)
  a43 = T(11266239266428//11593286722821)
  bhat1 = T(2756255671327//12835298489170)
  bhat2 = -T(10771552573575//22201958757719)
  bhat3 = T(9247589265047//10645013368117)
  bhat4 = T(2193209047091//5459859503100)
  c3 = T2(3//5)
  c2 = 2γ
  θ = c3/c2
  α31 = ((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
  α32 = ((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)
  θ = 1/c2
  α41 = ((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
  α42 = ((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)
  ESDIRK4Tableau(γ,a31,a32,a41,a42,a43,bhat1,bhat2,bhat3,bhat4,c3,α31,α32,α41,α42)
end

struct Cash4Tableau{T,T2}
  γ::T
  a21::T
  a31::T
  a32::T
  a41::T
  a42::T
  a43::T
  a51::T
  a52::T
  a53::T
  a54::T
  b1hat1::T
  b2hat1::T
  b3hat1::T
  b4hat1::T
  b1hat2::T
  b2hat2::T
  b3hat2::T
  b4hat2::T
  c2::T2
  c3::T2
  c4::T2
end

#=
Extrapolation for Cash interior step 3
dt = c1-c2 since interval is [c2,c1] and c1 = 0
c2 < c1, so z₂ is the left
θ =  (c3-c1)/dt the extrapolation point
z = dt*k

z₂ + Θ*(-4dt*z₂ - 2dt*z₁ - 6y₀ + Θ*(3dt*z₂ + 3z₁ + 6y₀ - 6y₁ ) + 6y₁)/dt

Coefficient on z₁:
(-2θ + 3θ^2)

Coefficient on z₂:
(1 + (-4θ + 3θ^2))

Coefficient on y₁-y₀:
(6θ*(1-θ)/dt)

# Write only in terms of z primatives
y₁ = uprev + a21*z₁ + γ*z₂
y₀ = uprev + γ*z₁
y₁-y₀ = (a21-γ)*z₁ + γ*z₂

θ = 1.1
Full z₁ coefficient: (-2θ + 3θ^2) + (6θ*(1-θ)/dt)*(a21-γ)
Full z₂ coefficient: (1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/dt)*γ

f(θ)= (-2θ + 3θ^2) + (6θ*(1-θ)/dt)*(a21-γ)
g(θ) = (1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/dt)*γ
t = linspace(0,1.5,100)
y = f.(t)
z = g.(t)
plot(t,y)
plot!(t,z)

The extrapolation is really bad that far
Hairer's extrapolation is no better.
Using constant extrapolations
=#

function Cash4Tableau(T,T2)
  γ = T(0.435866521508)
  a21 = T(-1.13586652150)
  a31 = T(1.08543330679)
  a32 = -T(0.721299828287)
  a41 = T(0.416349501547)
  a42 = T(0.190984004184)
  a43 = T(-0.118643265417)
  a51 = T(0.896869652944)
  a52 = T(0.0182725272734)
  a53 = -T(0.0845900310706)
  a54 = -T(0.266418670647)
  b1hat1 = T(1.05646216107052)
  b2hat1 = -T(0.0564621610705236)
  b3hat1 = T(0)
  b4hat1 = T(0)
  b1hat2 = T(0.776691932910)
  b2hat2 = T(0.0297472791484)
  b3hat2 = -T(0.0267440239074)
  b4hat2 = T(0.220304811849)
  c2 = -T2(0.7)
  c3 = T2(0.8)
  c4 = T2(0.924556761814)
  Cash4Tableau(γ,a21,a31,a32,a41,a42,a43,a51,a52,a53,a54,
               b1hat1,b2hat1,b3hat1,b4hat1,b1hat2,b2hat2,b3hat2,b4hat2,c2,c3,c4)
end

struct Hairer4Tableau{T,T2}
  γ::T
  a21::T
  a31::T
  a32::T
  a41::T
  a42::T
  a43::T
  a51::T
  a52::T
  a53::T
  a54::T
  bhat1::T
  bhat2::T
  bhat3::T
  bhat4::T
  c2::T2
  c3::T2
  c4::T2
  r11::T
  r12::T
  r13::T
  r14::T
  r21::T
  r22::T
  r23::T
  r24::T
  r31::T
  r32::T
  r33::T
  r34::T
  r41::T
  r42::T
  r43::T
  r44::T
  r51::T
  r52::T
  r53::T
  r54::T
  α21::T
  α31::T
  α32::T
  α41::T
  α43::T
end

function Hairer4Tableau(T,T2)
  γ = T(1//4)
  c2 = T(3//4)
  c3 = T(11//20)
  c4 = T(1//2)

  #=
  α21 = T(2)
  α31 = T(42//25)
  α32 = -T(4//25)
  α41 = T(89//68)
  α42 = -T(25//136)
  α43 = T(15//136)
  α51 = -T(37//12)
  α52 = -T(103//24)
  α53 = T(275//8)
  α54 = -T(85//3)

  alpha = -inv(A)*γ

  α = [-1 0 0 0 0
       α21 -1 0 0 0
       α31 α32 -1 0 0
       α41 α42 α43 -1 0
       α51 α52 α53 α54 -1]
  A α = -γ
  A = -γ*inv(α)

  Now zⱼ = fⱼ + ∑α_ⱼᵢ zᵢ
  =#

  a11 = T(1//4)
  a21 = T(1//2)
  a22 = T(1//4)
  a31 = T(17//50)
  a32 = T(-1//25)
  a33 = T(1//4)
  a41 = T(371//1360)
  a42 = T(-137//2720)
  a43 = T(15//544)
  a44 = T(1//4)
  a51 = T(25//24)
  a52 = T(-49//48)
  a53 = T(125//16)
  a54 = T(-85//12)

  #=
  e1 = -T(23//6)
  e2 = -T(17//12)
  e3 = T(125//4)
  e4 = -T(85//3)
  E = [e1 e2 e3 e4 0]

  bhat = [59//48,-17//96,225//32,-85//12,0]

  α = [-1 0 0 0 0
       α21 -1 0 0 0
       α31 α32 -1 0 0
       α41 α42 α43 -1 0
       e1 e2 e3 e4 -1]

  A = [γ 0 0 0 0
       a21 γ 0 0 0
       a31 a32 γ 0 0
       a41 a42 a43 γ 0
       a51 a52 a53 a54 γ]

  E = bhat'*inv(A)
  bhat = E*A
  =#

  bhat1 = T(59//48)
  bhat2 = T(-17//96)
  bhat3 = T(225//32)
  bhat4 = T(-85//12)

  #=
  d11 = T(61//27)
  d12 = T(-185//54)
  d13 = T(2525//18)
  d14 = T(-3740//27)
  d15 = T(-44//9)
  d21 = T(2315//81)
  d22 = T(1049//162)
  d23 = T(-27725//54)
  d24 = T(40460//81)
  d25 = T(557//27)
  d31 = T(-6178//81)
  d32 = T(-1607//81)
  d33 = T(20075//27)
  d34 = T(-56440//81)
  d35 = T(-718//27)
  d41 = T(3680//81)
  d42 = T(1360//81)
  d43 = T(-10000//27)
  d44 = T(27200//81)
  d45 = T(320//27)

  D = [d11 d12 d13 d14 d15
       d21 d22 d23 d24 d25
       d31 d32 d33 d34 d35
       d41 d42 d43 d44 d45]
  R = (D*A)'
  =#

  r11 = T(11//3)
  r12 = T(-463//72)
  r13 = T(217//36)
  r14 = T(-20//9)
  r21 = T(11//2)
  r22 = T(-385//16)
  r23 = T(661//24)
  r24 = T(-10//1)
  r31 = T(-125//18)
  r32 = T(20125//432)
  r33 = T(-8875//216)
  r34 = T(250//27)
  r41 = T(0)
  r42 = T(-85//4)
  r43 = T(85//6)
  r44 = T(0//1)
  r51 = T(-11//9)
  r52 = T(557//108)
  r53 = T(-359//54)
  r54 = T(80//27)

  # c2/γ
  α21 = T(3)
  #=
  # Prediction alphas from Hairer
  # Predict z3 from z1 and z2
  A = [c1 c2
  γ*c1 a21*c1+γ*c2]
  b = [c3,a31*c1+a32*c2+γ*c3]
  A\b
  =#
  α31 = T(88//100)
  α32 = T(44//100)
  #=
  # Predict z4 from z1 and z3
  A = [c1   c3
       γ*c1 a31*c1+a32*c2+γ*c3]
  b = [c4,a41*c1+a42*c2+a43*c3+γ*c4]
  A\b
  =#
  α41 = T(3//17)
  α43 = T(155//187)

 Hairer4Tableau(γ,a21,a31,a32,a41,a42,a43,a51,a52,a53,a54,
                 bhat1,bhat2,bhat3,bhat4,c2,c3,c4,r11,r12,r13,r14,
                 r21,r22,r23,r24,r31,r32,r33,r34,r41,r42,r43,r44,r51,
                 r52,r53,r54,α21,α31,α32,α41,α43)
end



function Hairer42Tableau(T,T2)
  γ  = T(4//15)
  c2 = T2(23//30)
  c3 = T2(17//30)
  c4 = T2(2881//28965)+γ
  #=
  α21 = T(15//8)
  α31 = T(1577061//922880)
  α32 = -T(23427//115360)
  α41 = T(647163682356923881//2414496535205978880)
  α42 = -T(593512117011179//3245291041943520)
  α43 = T(559907973726451//1886325418129671)
  α51 = T(724545451//796538880)
  α52 = -T(830832077//267298560)
  α53 = T(30957577//2509272)
  α54 = -T(69863904375173//6212571137048)

  α = [-1 0 0 0 0
       α21 -1 0 0 0
       α31 α32 -1 0 0
       α41 α42 α43 -1 0
       α51 α52 α53 α54 -1]
  A = -γ*inv(α)
  =#
  a21 = T(1//2)
  a31 = T(51069//144200)
  a32 = T(-7809//144200)
  a41 = T(12047244770625658//141474406359725325)
  a42 = T(-3057890203562191//47158135453241775)
  a43 = T(2239631894905804//28294881271945065)
  a51 = T(181513//86430)
  a52 = T(-89074//116015)
  a53 = T(83636//34851)
  a54 = T(-69863904375173//23297141763930)

  #=

  A = [γ 0 0 0 0
       a21 γ 0 0 0
       a31 a32 γ 0 0
       a41 a42 a43 γ 0
       a51 a52 a53 a54 γ]

  A = convert(Array{Rational{BigInt}},A)

  e1 = T(7752107607//11393456128)
  e2 = -T(17881415427//11470078208)
  e3 = T(2433277665//179459416)
  e4 = -T(96203066666797//6212571137048)
  E = [e1 e2 e3 e4 0]

  bhat = E*A
  =#

  bhat1 = T(33665407//11668050)
  bhat2 = T(-2284766//15662025)
  bhat3 = T(11244716//4704885)
  bhat4 = T(-96203066666797//23297141763930)

  #=
  d11 = T(24.74416644927758)
  d12 = -T(4.325375951824688)
  d13 = T(41.39683763286316)
  d14 = T(-61.04144619901784)
  d15 = T(-3.391332232917013)
  d21 = T(-51.98245719616925)
  d22 = T(10.52501981094525)
  d23 = T(-154.2067922191855)
  d24 = T(214.3082125319825)
  d25 = T(14.71166018088679)
  d31 = T(33.14347947522142)
  d32 = T(-19.72986789558523)
  d33 = T(230.4878502285804)
  d34 = T(-287.6629744338197)
  d35 = T(-18.99932366302254)
  d41 = T(-5.905188728329743)
  d42 = T(13.53022403646467)
  d43 = T(-117.6778956422581)
  d44 = T(134.3962081008550)
  d45 = T(8.678995715052762)
  =#

  r11 = T(6.776439256624082)
  r12 = T(-14.066831911883533)
  r13 = T(16.204808856162565)
  r14 = T(-6.8143005003361985)
  r21 = T(3.166691382949011)
  r22 = T(-14.034196189427504)
  r23 = T(15.497198116229603)
  r24 = T(-5.3974733381957005)
  r31 = T(-1.9310469085972866)
  r32 = T(11.146663701107887)
  r33 = T(-6.9009212321038405)
  r34 = T(0.085120800673252)
  r41 = T(-6.107728468864632)
  r42 = T(13.031255018633459)
  r43 = T(-19.734599430149146)
  r44 = T(9.812254180511282)
  r51 = T(-0.9043552621112034)
  r52 = T(3.9231093815698106)
  r53 = T(-5.066486310139344)
  r54 = T(2.3143988573474035)

  # c2/γ
  α21 = T(23//8)
  α31 = T(0.9838473040915402)
  α32 = T(0.3969226768377252)
  α41 = T(0.6563374010466914)
  α43 = T(0.3372498196189311)

  Hairer4Tableau(γ,a21,a31,a32,a41,a42,a43,a51,a52,a53,a54,
                 bhat1,bhat2,bhat3,bhat4,c2,c3,c4,r11,r12,r13,r14,
                 r21,r22,r23,r24,r31,r32,r33,r34,r41,r42,r43,r44,r51,
                 r52,r53,r54,α21,α31,α32,α41,α43)
end

struct Kvaerno4Tableau{T,T2}
  γ::T
  a31::T
  a32::T
  a41::T
  a42::T
  a43::T
  a51::T
  a52::T
  a53::T
  a54::T
  c3::T2
  c4::T2
  α21::T
  α31::T
  α32::T
  α41::T
  α42::T
end

#=
# Kvaerno4
# Predict z3 from Hermite z2 and z1

c2 = 2γ
θ = c3/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict z4 from Hermite z2 and z1

θ = c4/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)
=#

function Kvaerno4Tableau(T,T2)
  γ = T(0.4358665215)
  a31 = T(0.140737774731968)
  a32 = T(-0.108365551378832)
  a41 = T(0.102399400616089)
  a42 = T(-0.376878452267324)
  a43 = T(0.838612530151233)
  a51 = T(0.157024897860995)
  a52 = T(0.117330441357768)
  a53 = T(0.61667803039168)
  a54 = T(-0.326899891110444)
  c3 = T2(0.468238744853136)
  c4 = T2(1)
  α21 = T(2) # c2/γ
  α31 = T(0.462864521870446)
  α32 = T(0.537135478129554)
  α41 = T(-0.14714018016178376)
  α42 = T(1.1471401801617838)
  Kvaerno4Tableau(γ,a31,a32,a41,a42,a43,a51,a52,a53,a54,
                  c3,c4,α21,α31,α32,α41,α42)
end

struct KenCarp4Tableau{T,T2}
  γ::T
  a31::T
  a32::T
  a41::T
  a42::T
  a43::T
  a51::T
  a52::T
  a53::T
  a54::T
  a61::T
  a63::T
  a64::T
  a65::T
  c3::T2
  c4::T2
  c5::T2
  α21::T
  α31::T
  α32::T
  α41::T
  α42::T
  α51::T
  α52::T
  α53::T
  α54::T
  α61::T
  α62::T
  α63::T
  α64::T
  α65::T
  bhat1::T
  bhat3::T
  bhat4::T
  bhat5::T
  bhat6::T
end

#=
# KenCarp4
# Predict z3 from Hermite z2 and z1

c2 = 2γ
θ = c3/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict z4 from Hermite z2 and z1
θ = c4/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict z5 from Hermite z2 and z1
θ = c5/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict z5 from z1 and z4

θ = c5/c4
dt = c4

y₀ = uprev
y₁ = uprev + a41*z₁ + a42*z₂ + a43*z₃ + γ*z₄
y₁-y₀ = a41*z₁ + a42*z₂ + a43*z₃ + γ*z₄

(1 + (-4θ + 3θ^2) + a31*(6θ*(1-θ)/dt))*z₁ +
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))*z₅
+ (6θ*(1-θ)/dt)*(a52*z₂ + a53*z₃ + a54*z₄)

(1 + (-4θ + 3θ^2) + a41*(6θ*(1-θ)/dt))
(6θ*(1-θ)/dt)*a42
(6θ*(1-θ)/dt)*a43
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))

# Predict last stage from z1 and z5

θ = 1/c5
dt = c5

y₀ = uprev
y₁ = uprev + a51*z₁ + a52*z₂ + a53*z₃ + a54*z₄ + γ*z₅
y₁-y₀ = a51*z₁ + a52*z₂ + a53*z₃ + a54*z₄ + γ*z₅

(1 + (-4θ + 3θ^2) + a31*(6θ*(1-θ)/dt))*z₁ +
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))*z₅
+ (6θ*(1-θ)/dt)*(a52*z₂ + a53*z₃ + a54*z₄)

(1 + (-4θ + 3θ^2) + a51*(6θ*(1-θ)/dt))
(6θ*(1-θ)/dt)*a52
(6θ*(1-θ)/dt)*a53
(6θ*(1-θ)/dt)*a54
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))

=#
function KenCarp4Tableau(T,T2)
  γ = T(1//4)
  a31 = T(8611//62500)
  a32 = -T(1743//31250)
  a41 = T(5012029//34652500)
  a42 = -T(654441//2922500)
  a43 = T(174375//388108)
  a51 = T(15267082809//155376265600)
  a52 = -T(71443401//120774400)
  a53 = T(730878875//902184768)
  a54 = T(2285395//8070912)
  a61 = T(82889//524892)
  a63 = T(15625//83664)
  a64 = T(69875//102672)
  a65 = -T(2260//8211)
  c3 = T2(83//250)
  c4 = T2(31//50)
  c5 = T2(17//20)
  bhat1 = T(4586570599//29645900160)
  bhat3 = T(178811875//945068544)
  bhat4 = T(814220225//1159782912)
  bhat5 = -T(3700637//11593932)
  bhat6 = T(61727//225920)
  α21 = T(2) # c2/γ
  α31 = T(42//125)
  α32 = T(83//125)
  α41 = T(-6//25)
  α42 = T(31//25)
  α51 = T(914470432//2064665255)
  α52 = T(798813//724780)
  α53 = T(-824765625//372971788)
  α54 = T(49640//29791)
  α61 = T(288521442795//954204491116)
  α62 = T(2224881//2566456)
  α63 = T(-1074821875//905317354)
  α64 = T(-3360875//8098936)
  α65 = T(7040//4913)
  KenCarp4Tableau(γ,a31,a32,a41,a42,a43,a51,a52,a53,a54,a61,a63,a64,a65,
                  c3,c4,c5,α21,α31,α32,α41,α42,α51,α52,α53,α54,
                  α61,α62,α63,α64,α65,bhat1,bhat3,bhat4,bhat5,bhat6)
end

struct Kvaerno5Tableau{T,T2}
  γ::T
  a31::T
  a32::T
  a41::T
  a42::T
  a43::T
  a51::T
  a52::T
  a53::T
  a54::T
  a61::T
  a63::T
  a64::T
  a65::T
  a71::T
  a73::T
  a74::T
  a75::T
  a76::T
  c3::T2
  c4::T2
  c5::T2
  c6::T2
  α31::T
  α32::T
  α41::T
  α42::T
  α43::T
  α51::T
  α52::T
  α53::T
  α61::T
  α62::T
  α63::T
end

#=
# Kvaerno5
# Predict z3 from Hermite z2 and z1

c2 = 2γ
θ = c3/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict others from z1 and z3 since it covers [0,1.23]

dt = c3 since interval is [c1,c3] and c1 = 0
θ =  c4/c3, c5/c3, c6/c3, c7/c3
z = dt*k

z₁ + Θ*(-4dt*z₁ - 2dt*z₃ - 6y₀ + Θ*(3dt*z₁ + 3z₃ + 6y₀ - 6y₁ ) + 6y₁)/dt

(1 + (-4θ + 3θ^2))*z₁ + (-2θ + 3θ^2)*z₃ + (6θ*(1-θ)/dt)*(y₁-y₀)

y₀ = uprev
y₁ = uprev + a31*z₁ + a32*z₂ + γ*z₃
y₁-y₀ = a31*z₁ + a32*z₂ + γ*z₃

(1 + (-4θ + 3θ^2) + a31*(6θ*(1-θ)/dt))*z₁ +
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))*z₃ + (6θ*(1-θ)/dt)*a32*z₂

dt = c3
θ = c4/c3
(1 + (-4θ + 3θ^2) + a31*(6θ*(1-θ)/dt))
(6θ*(1-θ)/dt)*a32
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))

θ = c5/c3
(1 + (-4θ + 3θ^2) + a31*(6θ*(1-θ)/dt))
(6θ*(1-θ)/dt)*a32
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))

θ = c6/c3
(1 + (-4θ + 3θ^2) + a31*(6θ*(1-θ)/dt))
(6θ*(1-θ)/dt)*a32
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))
=#

function Kvaerno5Tableau(T,T2)
  γ = T(0.26)
  a31 = T(0.13)
  a32 = T(0.84033320996790809)
  a41 = T(0.22371961478320505)
  a42 = T(0.47675532319799699)
  a43 = -T(0.06470895363112615)
  a51 = T(0.16648564323248321)
  a52 = T(0.10450018841591720)
  a53 = T(0.03631482272098715)
  a54 = -T(0.13090704451073998)
  a61 = T(0.13855640231268224)
  a63 = -T(0.04245337201752043)
  a64 = T(0.02446657898003141)
  a65 = T(0.61943039072480676)
  a71 = T(0.13659751177640291)
  a73 = -T(0.05496908796538376)
  a74 = -T(0.04118626728321046)
  a75 = T(0.62993304899016403)
  a76 = T(0.06962479448202728)
  α21 = T(2) # c2/γ
  α31 = T(-1.366025403784441)
  α32 = T(2.3660254037844357)
  α41 = T(-0.19650552613122207)
  α42 = T(0.8113579546496623)
  α43 = T(0.38514757148155954)
  α51 = T(0.10375304369958693)
  α52 = T(0.937994698066431)
  α53 = T(-0.04174774176601781)
  α61 = T(-0.17281112873898072)
  α62 = T(0.6235784481025847)
  α63 = T(0.5492326806363959)
  c3 = T(1.230333209967908)
  c4 = T(0.895765984350076)
  c5 = T(0.436393609858648)
  c6 = T(1)
  Kvaerno5Tableau(γ,a31,a32,a41,a42,a43,a51,a52,a53,a54,
                  a61,a63,a64,a65,a71,a73,a74,a75,a76,
                  c3,c4,c5,c6,α31,α32,α41,α42,α43,α51,α52,α53,
                  α61,α62,α63)
end

struct KenCarp5Tableau{T,T2}
  γ::T
  a31::T
  a32::T
  a41::T
  a43::T
  a51::T
  a53::T
  a54::T
  a61::T
  a63::T
  a64::T
  a65::T
  a71::T
  a73::T
  a74::T
  a75::T
  a76::T
  a81::T
  a84::T
  a85::T
  a86::T
  a87::T
  c3::T2
  c4::T2
  c5::T2
  c6::T2
  c7::T2
  α31::T
  α32::T
  α41::T
  α42::T
  α51::T
  α52::T
  α61::T
  α62::T
  α71::T
  α72::T
  α73::T
  α74::T
  α75::T
  α81::T
  α82::T
  α83::T
  α84::T
  α85::T
  bhat1::T
  bhat4::T
  bhat5::T
  bhat6::T
  bhat7::T
  bhat8::T
end

#=
# KenCarp5
# Predict z3 from Hermite z2 and z1

c2 = 2γ
θ = c3/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict z4 from z2 and z1
θ = c4/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict z5 from z2 and z1
θ = c5/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict z6 from z2 and z1
θ = c6/c2
dt = c2
((1 + (-4θ + 3θ^2)) + (6θ*(1-θ)/c2)*γ)
((-2θ + 3θ^2) + (6θ*(1-θ)/c2)*γ)

# Predict z7 from z5 and z1
θ = c7/c5
dt = c5

(1 + (-4θ + 3θ^2))*z₁ + (-2θ + 3θ^2)*z₃ + (6θ*(1-θ)/dt)*(y₁-y₀)
y₁-y₀ = a51*z₁ + a52*z₂ + a53*z₃ + a54*z₄ + γ*z₅

(1 + (-4θ + 3θ^2) + a51*(6θ*(1-θ)/dt))
(6θ*(1-θ)/dt)*a52
(6θ*(1-θ)/dt)*a53
(6θ*(1-θ)/dt)*a54
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))

# Predict z8 from z5 and z1
θ = 1/c5
dt = c5

(1 + (-4θ + 3θ^2) + a51*(6θ*(1-θ)/dt))
(6θ*(1-θ)/dt)*a52
(6θ*(1-θ)/dt)*a53
(6θ*(1-θ)/dt)*a54
(-2θ + 3θ^2 + γ*(6θ*(1-θ)/dt))

=#

function KenCarp5Tableau(T,T2)
  γ = T(41//200)
  a31 = T(41//400)
  a32 = -T(567603406766//11931857230679)
  a41 = T(683785636431//9252920307686)
  a43 = -T(110385047103//1367015193373)
  a51 = T(3016520224154//10081342136671)
  a53 = T(30586259806659//12414158314087)
  a54 = -T(22760509404356//11113319521817)
  a61 = T(218866479029//1489978393911)
  a63 = T(638256894668//5436446318841)
  a64 = -T(1179710474555//5321154724896)
  a65 = -T(60928119172//8023461067671)
  a71 = T(1020004230633//5715676835656)
  a73 = T(25762820946817//25263940353407)
  a74 = -T(2161375909145//9755907335909)
  a75 = -T(211217309593//5846859502534)
  a76 = -T(4269925059573//7827059040749)
  a81 = -T(872700587467//9133579230613)
  a84 = T(22348218063261//9555858737531)
  a85 = -T(1143369518992//8141816002931)
  a86 = -T(39379526789629//19018526304540)
  a87 = T(32727382324388//42900044865799)
  bhat1 = -T(975461918565//9796059967033)
  bhat4 = T(78070527104295//32432590147079)
  bhat5 = -T(548382580838//3424219808633)
  bhat6 = -T(33438840321285//15594753105479)
  bhat7 = T(3629800801594//4656183773603)
  bhat8 = T(4035322873751//18575991585200)
  c3 = T2(2935347310677//11292855782101)
  c4 = T2(1426016391358//7196633302097)
  c5 = T2(92//100)
  c6 = T2(24//100)
  c7 = T2(3//5)
  α31 = T(169472355998441//463007087066141)
  α32 = T(293534731067700//463007087066141)
  α41 = T(152460326250177//295061965385977)
  α42 = T(142601639135800//295061965385977)
  α51 = T(-51//41)
  α52 = T(92//41)
  α61 = T(17//41)
  α62 = T(24//41)
  α71 = T(13488091065527792//122659689776876057)
  α72 = T(-3214953045//3673655312)
  α73 = T(550552676519862000//151043064207496529)
  α74 = T(-409689169278408000//135215758621947439)
  α75 = T(3345//12167)
  α81 = T(1490668709762032//122659689776876057)
  α82 = T(5358255075//14694621248)
  α83 = T(-229396948549942500//151043064207496529)
  α84 = T(170703820532670000//135215758621947439)
  α85 = T(30275//24334)

  KenCarp5Tableau(γ,a31,a32,a41,a43,a51,a53,a54,a61,a63,a64,a65,
                  a71,a73,a74,a75,a76,a81,a84,a85,a86,a87,
                  c3,c4,c5,c6,c7,α31,α32,α41,α42,α51,α52,
                  α61,α62,α71,α72,α73,α74,α75,α81,α82,α83,α84,α85,
                  bhat1,bhat4,bhat5,bhat6,bhat7,bhat8)
end
