def arctan_cordic(x, y, n):
    # *****************************************************************************80
    #
    ## ARCTAN_CORDIC returns the arctangent of an angle using the CORDIC method.
    #
    #  Licensing:
    #
    #    This code is distributed under the GNU LGPL license.
    #
    #  Modified:
    #
    #    28 June 2017
    #
    #  Author:
    #
    #    John Burkardt
    #
    #  Reference:
    #
    #    Jean-Michel Muller,
    #    Elementary Functions: Algorithms and Implementation,
    #    Second Edition,
    #    Birkhaeuser, 2006,
    #    ISBN13: 978-0-8176-4372-0,
    #    LC: QA331.M866.
    #
    #  Parameters:
    #
    #    Input, real X, Y, define the tangent of an angle as Y/X.
    #
    #    Input, integer N, the number of iterations to take.
    #    A value of 10 is low.  Good accuracy is achieved with 20 or more
    #    iterations.
    #
    #    Output, real THETA, the angle whose tangent is Y/X.
    #
    #  Local Parameters:
    #
    #    Local, real ANGLES(60) = arctan ( (1/2)^(0:59) )
    #
    import numpy as np

    angles = np.array([ \
        7.8539816339744830962E-01, \
        4.6364760900080611621E-01, \
        2.4497866312686415417E-01, \
        1.2435499454676143503E-01, \
        6.2418809995957348474E-02, \
        3.1239833430268276254E-02, \
        1.5623728620476830803E-02, \
        7.8123410601011112965E-03, \
        3.9062301319669718276E-03, \
        1.9531225164788186851E-03, \
        9.7656218955931943040E-04, \
        4.8828121119489827547E-04, \
        2.4414062014936176402E-04, \
        1.2207031189367020424E-04, \
        6.1035156174208775022E-05, \
        3.0517578115526096862E-05, \
        1.5258789061315762107E-05, \
        7.6293945311019702634E-06, \
        3.8146972656064962829E-06, \
        1.9073486328101870354E-06, \
        9.5367431640596087942E-07, \
        4.7683715820308885993E-07, \
        2.3841857910155798249E-07, \
        1.1920928955078068531E-07, \
        5.9604644775390554414E-08, \
        2.9802322387695303677E-08, \
        1.4901161193847655147E-08, \
        7.4505805969238279871E-09, \
        3.7252902984619140453E-09, \
        1.8626451492309570291E-09, \
        9.3132257461547851536E-10, \
        4.6566128730773925778E-10, \
        2.3283064365386962890E-10, \
        1.1641532182693481445E-10, \
        5.8207660913467407226E-11, \
        2.9103830456733703613E-11, \
        1.4551915228366851807E-11, \
        7.2759576141834259033E-12, \
        3.6379788070917129517E-12, \
        1.8189894035458564758E-12, \
        9.0949470177292823792E-13, \
        4.5474735088646411896E-13, \
        2.2737367544323205948E-13, \
        1.1368683772161602974E-13, \
        5.6843418860808014870E-14, \
        2.8421709430404007435E-14, \
        1.4210854715202003717E-14, \
        7.1054273576010018587E-15, \
        3.5527136788005009294E-15, \
        1.7763568394002504647E-15, \
        8.8817841970012523234E-16, \
        4.4408920985006261617E-16, \
        2.2204460492503130808E-16, \
        1.1102230246251565404E-16, \
        5.5511151231257827021E-17, \
        2.7755575615628913511E-17, \
        1.3877787807814456755E-17, \
        6.9388939039072283776E-18, \
        3.4694469519536141888E-18, \
        1.7347234759768070944E-18])

    x1 = x
    y1 = y
    #
    #  Account for signs.
    #
    if (x1 < 0.0 and y1 < 0.0):
        x1 = - x1
        y1 = - y1

    if (x1 < 0.0):
        x1 = - x1
        sign_factor = -1.0
    elif (y1 < 0.0):
        y1 = -y1
        sign_factor = -1.0
    else:
        sign_factor = +1.0

    theta = 0.0
    poweroftwo = 1.0

    for j in range(0, n):

        if (y1 <= 0.0):
            sigma = +1.0
        else:
            sigma = -1.0

        if (j < angles.size):
            angle = angles[j]
        else:
            angle = angle / 2.0

        x2 = x1 - sigma * poweroftwo * y1
        y2 = sigma * poweroftwo * x1 + y1

        theta = theta - sigma * angle

        x1 = x2
        y1 = y2

        poweroftwo = poweroftwo / 2.0

    theta = sign_factor * theta

    return theta