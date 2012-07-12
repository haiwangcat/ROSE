#ifndef BACKSTROKE_VALUEGRAPH_TYPES_H
#define	BACKSTROKE_VALUEGRAPH_TYPES_H

#include "CFGFilter.h"
#include <slicing/backstrokeCFG.h>
#include <slicing/backstrokeCDG.h>
#include <dataflowCfgFilter.h>
#include <boost/dynamic_bitset.hpp>
#include <boost/tuple/tuple.hpp>

#define VG_DEBUG 

namespace Backstroke
{

//typedef CFG<BackstrokeCFGNodeFilter> BackstrokeCFG;
typedef CFG<ssa_private::DataflowCfgFilter> BackstrokeCFG;
typedef CDG<BackstrokeCFG> BackstrokeCDG;
//typedef FilteredCFG BackstrokeCFG;

typedef BackstrokeCDG::ControlDependences ControlDependences;

//typedef boost::adjacency_list<boost::vecS, boost::vecS, boost::bidirectionalS,
//		BackstrokeCFG::Vertex, BackstrokeCFG::Edge> DAG;

typedef boost::dynamic_bitset<> PathSet;

typedef std::vector<SgInitializedName*> VarName;

    
SgMemberFunctionSymbol* getMemFuncSymbol(SgClassType* t, const std::string& name);

boost::tuple<
    SgMemberFunctionSymbol*,
    SgMemberFunctionSymbol*,
    SgMemberFunctionSymbol*>
buildThreeFuncDecl(SgClassDefinition* classDef, SgMemberFunctionDeclaration* funcDecl);



struct PhiNodeDependence
{
//	enum ControlDependenceType
//	{
//		cdTrue,
//		cdFalse,
//		cdCase,
//		cdDefault
//	};

	explicit PhiNodeDependence(int v)
	: version(v) {}

	//! One version member of the phi function.
	int version;

	//!  The SgNode on which the phi function has a control dependence for the version.
	SgNode* cdNode;

	////! The control dependence type.
	//ControlDependenceType cdType;

	////! If the control dependence is cdCase, this is the case value.
	//int caseValue;
};


struct VersionedVariable
{
	VersionedVariable() : version(0), isPseudoDef(false) {}
	VersionedVariable(const VarName& varName, int ver, bool pseudoDef = false)
	: name(varName), version(ver), isPseudoDef(pseudoDef) {}

	std::string toString() const;

    bool isNull() const { return name.empty(); }
    SgType* getType() const { return name.back()->get_type(); }
    SgExpression* getVarRefExp() const;
	
	//! The unique name of this variable.
	VarName name;

	//! The version of this variable in the SSA form.
	int version;

	//! Indicated if this variable is defined by a phi function.
	bool isPseudoDef;

	//! All versions it depends if this variable is a pseudo def.
	std::vector<PhiNodeDependence> phiVersions;
};




inline bool operator == (const VersionedVariable& var1, const VersionedVariable& var2)
{
	return var1.name == var2.name && var1.version == var2.version;
}

inline bool operator < (const VersionedVariable& var1, const VersionedVariable& var2)
{
	return var1.name < var2.name ||
		(var1.name == var2.name && var1.version < var2.version);
}

inline std::ostream& operator << (std::ostream& os, const VersionedVariable& var)
{
	return os << var.toString();
}


struct PathCondition
{
    int mask;
    int compTarget;
    bool equality;
};

struct PathInfo : PathSet
{
    PathInfo() {}
    PathInfo(const PathSet& paths) : PathSet(paths) {}
    
    //PathSet paths;
    std::vector<std::vector<std::pair<int, int> > > pathCond;
    
    bool isEmpty() const { return !any(); }
    
    PathInfo makeFullPath() const { return PathInfo(*this).set(); }
    
    PathInfo operator&(const PathInfo& p) const;
    
    PathInfo& operator&=(const PathInfo& p);
    PathInfo& operator|=(const PathInfo& p);
    PathInfo& operator-=(const PathInfo& p);
};

std::ostream& operator<<(std::ostream& os, const PathInfo& path);

//inline bool operator<(const PathInfo& p1, const PathInfo& p2)
//{ return paths < p2.paths; }

struct PathInfos : std::map<int, PathInfo>
{
    bool hasPath(int dagIdx, int pathIdx) const;

    std::string toString() const;
};

PathInfos operator&(const PathInfos& path1, const PathInfos& path2);
PathInfos operator|(const PathInfos& path1, const PathInfos& path2);

} // end of Backstroke


#endif	/* BACKSTROKE_VALUEGRAPH_TYPES_H */
