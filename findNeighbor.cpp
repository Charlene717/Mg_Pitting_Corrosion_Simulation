#include <mex.h>
#include <cstdio>
#include <cstring>
#include <map>
#include "perm.h"

const int NUM_NODES_PER_ELEM = 8;
const int CONNECT_NUM = 4;
const int MAX_NUM_NEIGHBORS = 6;

const int NUM_PERM = 70;
#define PERM PERM_8_4

struct Element {
	double node[NUM_NODES_PER_ELEM];
};

struct Connection {
	double node[CONNECT_NUM];
	bool operator<(const Connection& c) const {
		for (int i = 0; i < CONNECT_NUM; ++i) {
			if (node[i] < c.node[i]) {
				return true;
			}
			if (node[i] > c.node[i]) {
				return false;
			}
		}
		return false;
	}
};

struct Neighborhood {
	double node[MAX_NUM_NEIGHBORS];
	void add(int n) {
		for (int i = 0; i < MAX_NUM_NEIGHBORS; ++i) {
			if (node[i] == 0) {
				node[i] = n + 1;
				break;
			}
		}
	}
};

typedef std::map<Connection, int> MapType;

void findNeighbor(double* nbrList, const double* nodeList, int numElem) {
	Neighborhood* nbh = (Neighborhood*)nbrList;
	memset(nbh, 0, sizeof(Neighborhood) * numElem);
	const Element* elem = (const Element*)nodeList;
	MapType cntMap;
	//Connection c1 = {1, 2, 3, 4};
	//cntMap[c1] = 1;
	//printf("%d\n", cntMap.find(c1) == cntMap.end());
	for (int i = 0; i < numElem; ++i) {
		for (int j = 0; j < NUM_PERM; ++j) {
			Connection cnt;
			for (int k = 0; k < CONNECT_NUM; ++k) {
				cnt.node[k] = elem[i].node[PERM[j][k]];
			}
			MapType::iterator it = cntMap.find(cnt);
			if (it == cntMap.end()) {
				cntMap[cnt] = i;
			} else {
				nbh[it->second].add(i);
				nbh[i].add(it->second);
				cntMap.erase(it);
			}
		}
	}
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	const double* nodeList = mxGetPr(prhs[0]);
	int numElem = mxGetN(prhs[0]);
	plhs[0] = mxCreateDoubleMatrix(MAX_NUM_NEIGHBORS, numElem, mxREAL);
	double* nbrList = mxGetPr(plhs[0]);
	findNeighbor(nbrList, nodeList, numElem);
}