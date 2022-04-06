package controls;

import flixel.input.keyboard.FlxKey;

class ControllerUtil
{
	public static function keyFromString(word:String):FlxKey
	{
		switch (word.toLowerCase())
		{
			case 'up':
				return UP;
			case 'left':
				return LEFT;
			case 'right':
				return RIGHT;
			case 'down':
				return DOWN;
			case 'q':
				return Q;
			case 'w':
				return W;
			case 'e':
				return E;
			case 'r':
				return R;
			case 't':
				return T;
			case 'y':
				return Y;
			case 'u':
				return U;
			case 'i':
				return I;
			case 'o':
				return O;
			case 'p':
				return P;
			case 'a':
				return A;
			case 's':
				return S;
			case 'd':
				return D;
			case 'f':
				return F;
			case 'g':
				return G;
			case 'h':
				return H;
			case 'j':
				return J;
			case 'k':
				return K;
			case 'l':
				return L;
			case 'z':
				return Z;
			case 'x':
				return X;
			case 'c':
				return C;
			case 'v':
				return V;
			case 'b':
				return B;
			case 'n':
				return N;
			case 'm':
				return M;
			default:
				return NONE;
		}
	}
}
