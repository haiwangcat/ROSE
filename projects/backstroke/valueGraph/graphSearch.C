#include "valueGraph.h"
#include "pathNumGenerator.h"
#include <sageBuilder.h>
#include <boost/bind.hpp>
#include <boost/foreach.hpp>
//#include <boost/graph/graphviz.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/tuple/tuple.hpp>
#include <vector>

namespace Backstroke
{

using namespace std;

#define foreach BOOST_FOREACH


bool EventReverser::edgeBelongsToPath(const VGEdge& e, int dagIndex, int pathIndex) const
{
    ValueGraphEdge* edge = valueGraph_[e];
    
    // The ordered edge does not have path information, so trace its
    // corresponding normal edge.
    if (isOrderedEdge(edge))
    {
        VGEdge realEdge = *(boost::in_edges(
                boost::source(e, valueGraph_), valueGraph_).first);
        edge = valueGraph_[realEdge];
    }
    
    return edge->paths.hasPath(dagIndex, pathIndex);
}

set<EventReverser::VGEdge> EventReverser::getRouteFromSubGraph(int dagIndex, int pathIndex)
{
    //PathEdgeSelector edgeSelector(&valueGraph_, dagIndex, i);
    //SubValueGraph subgraph(valueGraph_, edgeSelector);

    // First, get the subgraph for the path.

    pair<int, int> path(dagIndex, pathIndex);
    set<VGVertex>& nodes = pathNodesAndEdges_[path].first;
    set<VGEdge>&   edges = pathNodesAndEdges_[path].second;
    foreach (const VGEdge& edge, boost::edges(valueGraph_))
    {
        if (edgeBelongsToPath(edge, dagIndex, pathIndex))
        {
            nodes.insert(boost::source(edge, valueGraph_));
            edges.insert(edge);
        }
    }
    nodes.insert(ssnode_);

    // To resolve the problem of binding an overloaded function.
    set<VGVertex>::const_iterator (set<VGVertex>::*findNode)
             (const set<VGVertex>::key_type&) const = &set<VGVertex>::find;
    set<VGEdge>::const_iterator (set<VGEdge>::*findEdge)
             (const set<VGEdge>::key_type&) const = &set<VGEdge>::find;
    SubValueGraph subgraph(valueGraph_,
                           boost::bind(findEdge, &edges, ::_1) != edges.end(),
                           boost::bind(findNode, &nodes, ::_1) != nodes.end());

//        string filename = "VG" + boost::lexical_cast<string>(i);
//        //cout << subgraph << endl;
//        const char* name = "ABCDE";
    
    //set<VGVertex> availableNodes;
    //availableNodes.insert(root_);
    
    getReversalRoute(dagIndex, valuesToRestore_[dagIndex]);

    // Get the route for this path.
    return getReversalRoute(dagIndex, pathIndex, subgraph, 
            valuesToRestore_[dagIndex], availableValues_[dagIndex]);
    
    // Generate the reverse function for this route.
    //generateReverseFunction(scope, route);

    // Fix all variable references.
    //SageInterface::fixVariableReferences(scope);
    //graphToDot(subgraph, filename);
}


namespace // anonymous namespace
{
    typedef EventReverser::VGVertex VGVertex;
    typedef EventReverser::VGEdge   VGEdge;
    typedef pair<vector<VGEdge>, int> RouteWithCost;
    typedef pair<vector<VGEdge>, PathInfo> RouteWithPaths;


    // A local structure to help find all routes.
    struct Route
    {
        Route() : cost(0) {}
        Route& operator=(Route& route)
        {
            edges.swap(route.edges);
            nodes.swap(route.nodes);
            cost = route.cost;
            paths = route.paths;
            return *this;
        }
        
        void addEdge(VGEdge e, const ArrayRegion& region = ArrayRegion())
        { 
            edges.push_back(e);
            regions.push_back(region);
        }
        
        void addVertices(VGVertex v1, VGVertex v2, const ArrayRegion& region = ArrayRegion())
        {
            nodes.push_back(boost::make_tuple(v1, v2, region));
        }

        vector<VGEdge> edges;
        
        // For each edge this vector records the array region information on it.
        // Note the size of this vector should always be the same at the vector 
        // of edges.
        vector<ArrayRegion> regions;
        
        vector<boost::tuple<VGVertex, VGVertex, ArrayRegion> > nodes;
        int cost;
        PathInfo paths;
    };
    
    inline bool operator<(const Route& r1, const Route& r2)
    { return r1.paths < r2.paths; }

    // Returns if the vector contains the second parameter
    // at the first member of each element.
    bool hasCycle(const Route& route, VGVertex node)
    {
        const vector<boost::tuple<VGVertex, VGVertex, ArrayRegion> >& nodes = route.nodes;
        typedef boost::tuple<VGVertex, VGVertex, ArrayRegion> VertexPair;
        foreach (const VertexPair& vpair, nodes)
        {
            if (vpair.get<1>() == node)
                return true;
        }
        return false;
    }
    
    bool hasCycle(const Route& route, VGVertex node, ArrayRegion region)
    {        
        vector<boost::tuple<VGVertex, VGVertex, ArrayRegion> > nodes = route.nodes;
        
        vector<ArrayRegion> regions;
        VGVertex parent = nodes.back().get<0>();
        do
        {
            if (parent == nodes.back().get<0>())
            {
                regions.push_back(nodes.back().get<2>());
                parent = nodes.back().get<1>();
                if (node == nodes.back().get<1>())
                {
                    ArrayRegion reg;
                    foreach (const ArrayRegion& r, regions)
                        reg = reg & r;
                    reg = reg & region;
                    return !reg.isEmpty();
                }
            }
            nodes.pop_back();
        } 
        while (!nodes.empty());
                
        return false;
                
#if 0
        VGVertex n = route.nodes.back().get<1>();
        return n == node;
        
        const vector<boost::tuple<VGVertex, VGVertex, ArrayRegion> >& nodes = route.nodes;
        vector<ArrayRegion> regions;
        typedef boost::tuple<VGVertex, VGVertex, ArrayRegion> VertexPair;
        foreach (const VertexPair& vpair, nodes)
        {
            regions.push_back(vpair.get<2>());
            if (vpair.get<1>() == node)
            {
                foreach (const ArrayRegion& r, regions)
                    if (region == r)
                        return true;
            }
        }
        return false;
#endif
    }
    
    // Returns if the given value graph node is a mu node and its DAG index is
    // the same as the given one.
    bool isMuNode(ValueGraphNode* node, int dagIndex)
    {
        if (MuNode* muNode = isMuNode(node))
        {
            if (dagIndex == muNode->dagIndex)
                return true;
        }
        return false;
    }
} // end of anonymous


map<VGEdge, EdgeInfo> EventReverser::getReversalRoute(
        int dagIndex,
        const set<VGVertex>& valsToRestore)
{
    map<VGVertex, vector<Route> > allRoutes;
    
    set<VGVertex> valuesToRestore = valsToRestore;
    
#if 0
    // Find all reverse function call node and put them into valuesToRestore set.
    foreach (VGVertex node, boost::vertices(valueGraph_))
    {
        FunctionCallNode* funcCallNode = isFunctionCallNode(valueGraph_[node]);
        // Note that now only reverse function call node will be add to route graph.
        if (funcCallNode && funcCallNode->isReverse)
            valuesToRestore.insert(node);
    }
#endif
    
    foreach (VGVertex valToRestore, valuesToRestore)
    {
        //// A flag for mu node search.
        //bool firstNode = true;
        
#if 0
        // For dummy nodes.
        if (ScalarValueNode* v = isScalarValueNode(valueGraph_[valToRestore]))
        {
            if (v->isTemp())
            {
                PathInfos paths = valueGraph_[*(boost::out_edges(valToRestore, valueGraph_).first)]->paths;
                if (paths.count(dagIndex) == 0 || !paths[dagIndex][pathIndex])
                {
                    continue;
                }
            }
        }
#endif
        
        // This stack stores all possible routes for the state variable.
        stack<Route> unfinishedRoutes;
        
#if 1
        {
            Route route;
            route.addVertices(valToRestore, VGVertex());
            if (boost::out_degree(valToRestore, valueGraph_) > 0)
            {
                VGEdge edge = *(boost::out_edges(valToRestore, valueGraph_).first);
                route.paths = valueGraph_[edge]->paths[dagIndex].makeFullPath();
                //cout << valueGraph_[valToRestore]->toString() << endl;
                //cout << "New route: " << route.paths << ' '  << valueGraph_[edge]->toString() << endl;
                unfinishedRoutes.push(route);
            }
        }
        
#else        
        // Initialize the stack.
        foreach (const VGEdge& edge, boost::out_edges(valToRestore, valueGraph_))
        {
            VGVertex tar = boost::target(edge, valueGraph_);
            
            // The current mu node is not connected to other nodes correctly.
            // Temporarily prevent the mu node from the search.
            
            if (isMuNode(valueGraph_[tar]))
                continue;

            Route route;
            route.edges.push_back(edge);
            route.nodes.push_back(make_pair(tar, valToRestore));
            route.paths = valueGraph_[edge]->paths[dagIndex];
            if (!route.paths.isEmpty())
                unfinishedRoutes.push(route);
        }
#endif

        while (!unfinishedRoutes.empty())
        {
            // Fetch a route.
            Route unfinishedRoute = unfinishedRoutes.top();
            unfinishedRoutes.pop();

            if (unfinishedRoute.nodes.empty())
                continue;
            // To prevent long time search, limit the nodes in the route no more
            // than 10.
            //if (unfinishedRoute.nodes.size() > 10)
            //    continue;

            // Get the node on the top, and find it out edges.
            VGVertex node = unfinishedRoute.nodes.back().get<0>();
            ArrayRegion region = unfinishedRoute.nodes.back().get<2>();
            //cout << "Node:" << valueGraph_[node]->toString() << " R: " << region << endl;
            
            
            // Currently, we forbid the route graph includes any function call nodes
            // which are not reverse ones. This will be modified in the future.
            FunctionCallNode* funcCallNode = isFunctionCallNode(valueGraph_[node]);
            if (funcCallNode && !funcCallNode->isReverse)
                continue;

            
            //if (availableNodes.count(node) > 0)
            // For a function call node, if its target is itself, keep searching.
            if ((node == ssnode_ /* || funcCallNode */) && node != valToRestore)
            {                
                //cout << "AVAILABLE: " << valueGraph_[node]->toString() << endl;
                
                Route& newRoute = unfinishedRoute;

                // Keep removing nodes from the stack if the node before this
                // node is its parent node.
                VGVertex parent;
                do
                {
                    parent = newRoute.nodes.back().get<1>();
                    newRoute.nodes.pop_back();
                    if (newRoute.nodes.empty()) 
                        break;
                } 
                while (parent == newRoute.nodes.back().get<0>());

                if (!newRoute.nodes.empty())
                {
                    unfinishedRoutes.push(newRoute);
                    continue;
                }

                // If there is no nodes in this route, this route is finished.
                for (size_t i = 0, s = newRoute.edges.size(); i < s; ++i)
                {
                    VGEdge edge = newRoute.edges[i];
                    int cost = valueGraph_[edge]->cost;
                    const ArrayRegion& region = newRoute.regions[i];
                    
                    // Make an approximation of the cost for partial array.
                    if (region.type == SingleElement)
                    {
                        if (region.diff)
                            cost *= 0.9;
                        else
                            cost *= 0.1;
                        //cout << "!!!" << cost << "\n";
                    }
                    newRoute.cost += cost;
                }

                vector<Route>& routes = allRoutes[valToRestore];
                routes.push_back(Route());
                // Swap instead of copy for performance.
                routes.back().edges.swap(newRoute.edges);
                routes.back().regions.swap(newRoute.regions);
                routes.back().paths = newRoute.paths;
                routes.back().cost = newRoute.cost;

                continue;
            }

            // If this node is an operator node or function call node, add all its operands.
            if (isOperatorNode(valueGraph_[node]) || isFunctionCallNode(valueGraph_[node]))
            {
                Route& newRoute = unfinishedRoute;
                foreach (const VGEdge& edge, boost::out_edges(node, valueGraph_))
                {
                    VGVertex tar = boost::target(edge, valueGraph_);
                    
                    //cout << "OPERAND: " << valueGraph_[tar]->toString() << endl;

                    // The the following function returns true if adding
                    // this edge will form a circle.
                    if (hasCycle(unfinishedRoute, tar, valueGraph_[edge]->region))
                        goto NEXT;
                }
                
                foreach (const VGEdge& edge, boost::out_edges(node, valueGraph_))
                {
                    VGVertex tar = boost::target(edge, valueGraph_);
                    newRoute.addEdge(edge, valueGraph_[edge]->region);
                    newRoute.addVertices(tar, node, valueGraph_[edge]->region);
                }
                unfinishedRoutes.push(newRoute);
                continue;
            }
            
            // For a vector/array node, we have to make sure to retrieve all its
            // elements' values. 
            if (isVectorNode(valueGraph_[node]))
            {
                // Now we only assume that there are three regions on edges: universal, single
                // element and its difference. Later we will consider to extend this limitation.
                
                vector<VGEdge> edges;
                foreach (const VGEdge& edge, boost::out_edges(node, valueGraph_))
                    edges.push_back(edge);
                
                //cout << "R: " << region << endl;
                
                size_t s = edges.size();
                for (size_t i = 0; i < s; ++i)
                {
                    VGVertex tar = boost::target(edges[i], valueGraph_);
                    ArrayRegion region1 = valueGraph_[edges[i]]->region & region;
                    //cout << "R1: " << region1 << endl;
                    
                    
                    if (hasCycle(unfinishedRoute, tar, region1))
                        continue;
                    
                    if (region1.isEmpty())
                        continue;
                    
                    
                    
                    bool indexUnknown = false;
                    VGVertex indexVertex;
                    if (!region1.var1.isConst())
                    {
                        if (valueGraph_[edges[i]]->region.type == SingleElement)
                        {
                            indexUnknown = true;
                            VersionedVariable var = valueGraph_[edges[i]]->region.var1.var;
                            //cout << var << endl;
                            ROSE_ASSERT(varVertexMap_.count(var));
                            indexVertex = varVertexMap_[var];
                        }
                    }
                    
                    // Here we detect if the region1 is an induction variable,
                    // and during all iterations it can represent region.
                    if (region1.isInductionVar())
                    {
                        //cout << "Induction var: " << region1 << endl;
                        region1 = region;
                    }
                    
                    if (region1 == region)
                    {
                        Route newRoute = unfinishedRoute;
                        newRoute.addEdge(edges[i], region1);
                        newRoute.addVertices(tar, node, region1);
                        newRoute.paths &= valueGraph_[edges[i]]->paths[dagIndex];
                        if (indexUnknown)
                        {
                            cout << ">>> Add index: " << valueGraph_[indexVertex]->toString() << endl;
                            newRoute.addVertices(indexVertex, VGVertex());
                        }
                        if (!newRoute.paths.isEmpty())
                            unfinishedRoutes.push(newRoute);
                        continue;
                    }
                                            
                    
                    // Here we temporarily assume that the region is either a single
                    // element or its difference.
                    ROSE_ASSERT(valueGraph_[edges[i]]->region.type == SingleElement);
                    //cout << ">>> VECTOR <<<\n";
                    
                    
                    for (size_t j = 0; j < s; ++j)
                    {
                        if (i == j)
                            continue;
                        
                        // Make sure the edge has the same path set.
                        if (valueGraph_[edges[i]]->paths[dagIndex] !=
                            valueGraph_[edges[j]]->paths[dagIndex])
                            continue;
                        
                        VGVertex tar2 = boost::target(edges[j], valueGraph_);
                        ArrayRegion region2 = valueGraph_[edges[j]]->region & !region1;
                        //cout << "R2: " << region2 << endl;
                        //cout << "R12: " << (region2 | region1) << endl;
                        //cout << ((region1 | region2) == region) << endl;
                        
                        
                        if (hasCycle(unfinishedRoute, tar2, region2))
                            continue;
                        
                        if (region2.isEmpty())
                            continue;
                    
                        if ((region1 | region2) == region)
                        {
                            Route newRoute = unfinishedRoute;
                            newRoute.addEdge(edges[i], region1);
                            newRoute.addEdge(edges[j], region2);
                            newRoute.addVertices(tar, node, region1);
                            newRoute.addVertices(tar2, node, region2);
                            if (indexUnknown)
                            {
                                cout << ">>> Add index: " << valueGraph_[indexVertex]->toString() << endl;
                                newRoute.addVertices(indexVertex, VGVertex());
                            }
                            newRoute.paths &= valueGraph_[edges[i]]->paths[dagIndex];
                            if (!newRoute.paths.isEmpty())
                                unfinishedRoutes.push(newRoute);
                        }
                    }
                }
                continue;
            } // end of if (isVectorNode(valueGraph_[node]))

            foreach (const VGEdge& edge, boost::out_edges(node, valueGraph_))
            {
                VGVertex tar = boost::target(edge, valueGraph_);
                
                // The current mu node is not connected to other nodes correctly.
                // Temporarily prevent the mu node from the search.
                //if (isMuEdge(edge))
                {
                    
                }
                
                // The the following function returns true if adding
                // this edge will form a cycle.
                if (hasCycle(unfinishedRoute, tar, valueGraph_[edge]->region))
                    continue;
                
                Route newRoute = unfinishedRoute;
                newRoute.addEdge(edge, valueGraph_[edge]->region);
                newRoute.addVertices(tar, node, valueGraph_[edge]->region);
                //cout << newRoute.paths << ' ' << valueGraph_[edge]->paths[dagIndex] << endl;
                
                
                if (isVectorElementNode(getSource(edge)) && isVectorNode(getTarget(edge)))
                {
                    VGVertex indexVertex;
                    VersionedVariable var = valueGraph_[edge]->region.var1.var;
                    ROSE_ASSERT(varVertexMap_.count(var));
                    indexVertex = varVertexMap_[var];

                    cout << ">> Add index: " << valueGraph_[indexVertex]->toString() << endl;
                    newRoute.addVertices(indexVertex, VGVertex());
                }
                
                newRoute.paths &= valueGraph_[edge]->paths[dagIndex];
                if (!newRoute.paths.isEmpty())
                    unfinishedRoutes.push(newRoute);
            } // end of foreach (const VGEdge& edge, boost::out_edges(node, valueGraph_))
NEXT:
            ;//firstNode = false;
        } // end of while (!unfinishedRoutes.empty())
    } // end of foreach (VGVertex valNode, valuesToRestore)
    
    //map<VGVertex, vector<RouteWithCost> > allRoutes;
    
    typedef map<VGVertex, vector<Route> >::value_type VertexWithRoute;
#if 0
    foreach (const VertexWithRoute& nodeWithRoutes, allRoutes)
    {
        cout << "\n\n\n" << valueGraph_[nodeWithRoutes.first]->toString() << "\n\n";
        foreach (const Route& route, nodeWithRoutes.second)
        {
            cout << '\n' << route.paths << " " << route.cost << "\n";
            ROSE_ASSERT(route.edges.size() == route.regions.size());
            for (size_t i = 0, s = route.edges.size(); i < s; ++i)
            //foreach (const VGEdge& edge, route.edges)
            {
                VGEdge edge = route.edges[i];
                VGVertex src = boost::source(edge, valueGraph_);
                VGVertex tgt = boost::target(edge, valueGraph_);
                cout << "<" << valueGraph_[src]->toString() << ", " <<
                        valueGraph_[tgt]->toString() << "> " << route.regions[i] << " ==> ";
            }
            cout << "\n";
        }
    }
#endif

    
    
    /**************************************************************************/
    // Now get the route for all state variables.
    
    // map<VGVertex, vector<RouteWithCost> > allRoutes;
    //pair<int, int> path = make_pair(dagIndex, pathIndex);
    //set<VGVertex>& nodesInRoute = routeNodesAndEdges_[path].first;
    //set<VGEdge>&   edgesInRoute = routeNodesAndEdges_[path].second;
    
    // The following map stores the cost of each edge and how many times it's shared
    // by different to-store values.
    map<VGEdge, pair<int, int> > costForEdges;
    
    // Collect cost information.
    foreach (const VGEdge& edge, boost::edges(valueGraph_))
    {
        int cost = valueGraph_[edge]->cost;
        const ArrayRegion& region = valueGraph_[edge]->region;

        // Make an approximation of the cost for partial array.
        if (region.type == SingleElement)
        {
            if (region.diff)
                cost *= 0.9;
            else
                cost *= 0.1;
        }
        
        costForEdges[edge] = make_pair(cost, 0);
    }
    
    // Make stats how many times an edge is shared by different to-store values.
    foreach (VertexWithRoute& nodeWithRoute, allRoutes)
    {
        set<VGEdge> edges;
        foreach (const Route& route, nodeWithRoute.second)
        {
            foreach (const VGEdge& edge, route.edges)
                edges.insert(edge);
        }
        
        foreach (const VGEdge& edge, edges)
        {
            //// A way to force the inverse of each function call is used.
            //if (isSgFunctionCallExp(subgraph[nodeWithRoute.first]->astNode))
            //    costForEdges[edge].second += 100;
            //else
                ++costForEdges[edge].second;
        }
    }      
    
    
    map<VGEdge, EdgeInfo> edgesInRoute;
    
    foreach (VertexWithRoute& nodeWithRoute, allRoutes)
    {
        //cout << nodeWithRoute.first << endl;
        
        vector<Route> routes;
        
        map<PathInfo, int> pathToCost;
        
        // For each path, find the route with minimum cost. 
        foreach (Route& route, nodeWithRoute.second)
        {
            float cost = 0;
            
            //RouteWithPaths& route = nodeWithRoute.second[i];
            for (size_t i = 0, s = route.edges.size(); i < s; ++i)
            {
                VGEdge& edge = route.edges[i];
                //route.second += subgraph[edge]->cost;
                pair<int, int> costWithCounter = costForEdges[edge];
                
                // Make an approximation of the cost for partial array.
                if (route.regions[i].type == SingleElement)
                {
                    if (route.regions[i].diff)
                        costWithCounter.first *= 0.9;
                    else
                        costWithCounter.first *= 0.1;
                }

                // In this way we make an approximation of the real cost in the
                // final route graph.
                cost += float(costWithCounter.first) / costWithCounter.second;
            }
            
            route.cost = static_cast<int>(cost);
            
            //cout << "Cost " << route.cost << '\n';
            //cout << "Paths: " << route.paths << '\n';
            
            
            //bool toInsert = true;
            //vector<Route> newRoutes;
            
            foreach (Route& route2, routes)
            {
                PathInfo p = route2.paths & route.paths;
                //cout << route.paths <<  ' ' << route2.paths << endl;
                //cout << "p: " << p << endl;
                if (p.any())
                {
                    if (cost < route2.cost)
                    {
                        //newRoutes.push_back(route);
                        route2.paths -= route.paths;
                    }
                    else
                    {
                        route.paths -= route2.paths;
                        //newRoutes.push_back(route);
                    }
                    //cout << "Inserted path: " << route.paths << endl;
                    //toInsert = false;
                }
            }
            //if (toInsert)
            routes.push_back(route);
            
            //routes.insert(routes.end(), newRoutes.begin(), newRoutes.end());
        }
        
        
        // Make sure the union of all paths is all path set.
        PathSet paths;
        foreach (const Route& route, routes)
        {
            //cout << ">>>" << route.paths << " cost: " << route.cost << endl;
            if (paths.empty())
                paths = route.paths;
            else
                paths |= route.paths;
        }
        //ROSE_ASSERT(!paths.flip().any());
        
        foreach (const Route& route, routes)
        {
            if (!route.paths.any())
                continue;
            
            for (size_t i = 0, s = route.edges.size(); i < s; ++i)
            //foreach (const VGEdge& edge, route.edges)
            {
                VGEdge edge = route.edges[i];
                
#if 1
                if (isVectorElementNode(getSource(edge)) && isVectorNode(getTarget(edge)))
                {
                    VGEdge newEdge = boost::add_edge(boost::source(edge, valueGraph_), ssnode_, valueGraph_).first;
                    valueGraph_[newEdge] = new StateSavingEdge(0, valueGraph_[edge]->paths, NULL);
                    edge = newEdge;
                }
#endif
                if (edgesInRoute.count(edge))
                    edgesInRoute[edge].region = edgesInRoute[edge].region | route.regions[i];
                else
                    edgesInRoute[edge].region = route.regions[i];
                
                PathInfo& paths = edgesInRoute[edge].paths[dagIndex];
                if (paths.empty())
                    paths = route.paths;
                else
                    paths |= route.paths;
                
                const PathInfo& origPaths = valueGraph_[edge]->paths[dagIndex];
                if (paths == origPaths)
                    paths = origPaths;
            }
            
        }
    }
    
    
#if 0
    typedef map<EventReverser::VGEdge, PathInfo>::value_type T;
    cout << "\n\n";
    foreach (const T& edgeWithPaths, edgesInRoute)
    {
        cout << edgeWithPaths.first << " : " << edgeWithPaths.second << "\n";
    }
    cout << "\n\n";
#endif

    return edgesInRoute;
}

set<EventReverser::VGEdge> EventReverser::getReversalRoute(
        int dagIndex,
        int pathIndex,
        const SubValueGraph& subgraph,
        const set<VGVertex>& valsToRestore,
        const set<VGVertex>& availableNodes)
{
    ROSE_ASSERT(0);
    map<VGVertex, vector<Route> > allRoutes;
    
    set<VGVertex> valuesToRestore = valsToRestore;
    // Find all reverse function call node and put them into valuesToRestore set.
    foreach (VGVertex node, boost::vertices(subgraph))
    {
        FunctionCallNode* funcCallNode = isFunctionCallNode(subgraph[node]);
        // Note that now only reverse function call node will be add to route graph.
        if (funcCallNode && funcCallNode->isReverse)
            valuesToRestore.insert(node);
    }
    
    foreach (VGVertex valToRestore, valuesToRestore)
    {
        //// A flag for mu node search.
        //bool firstNode = true;
        
        // For dummy nodes.
        if (ScalarValueNode* v = isScalarValueNode(valueGraph_[valToRestore]))
        {
            if (v->isTemp())
            {
                PathInfos paths = valueGraph_[*(boost::out_edges(valToRestore, valueGraph_).first)]->paths;
                if (paths.count(dagIndex) == 0 || !paths[dagIndex][pathIndex])
                {
                    continue;
                }
            }
        }
        
        
        Route route;
        route.addVertices(valToRestore, valToRestore);

        vector<Route> routes(1, route);

        // This stack stores all possible routes for the state variable.
        stack<Route> unfinishedRoutes;
        unfinishedRoutes.push(route);

        while (!unfinishedRoutes.empty())
        {
            // Fetch a route.
            Route unfinishedRoute = unfinishedRoutes.top();
            unfinishedRoutes.pop();

            if (unfinishedRoute.nodes.empty())
                continue;
            // To prevent long time search, limit the nodes in the router no more
            // than 10.
            //if (unfinishedRoute.nodes.size() > 10)
            //    continue;

            // Get the node on the top, and find it out edges.
            VGVertex node = unfinishedRoute.nodes.back().get<0>();
            
            
            // Currently, we forbid the route graph includes any function call nodes
            // which are not reverse ones. This will be modified in the future.
            FunctionCallNode* funcCallNode = isFunctionCallNode(subgraph[node]);
            if (funcCallNode && !funcCallNode->isReverse)
                continue;

            
            //if (availableNodes.count(node) > 0)
            // For a function call node, if its target is itself, keep searching.
            if ((node == ssnode_ || funcCallNode) && node != valToRestore)
            {                
                //cout << "AVAILABLE: " << valueGraph_[node]->toString() << endl;
                
                Route& newRoute = unfinishedRoute;

                // Keep removing nodes from the stack if the node before this
                // node is its parent node.
                VGVertex parent;
                do
                {
                    parent = newRoute.nodes.back().get<1>();
                    newRoute.nodes.pop_back();
                    if (newRoute.nodes.empty()) break;
                } while (parent == newRoute.nodes.back().get<0>());

                if (!newRoute.nodes.empty())
                {
                    unfinishedRoutes.push(newRoute);
                    continue;
                }

#if 0
                foreach (const VGEdge& e, newRoute.edges)
                    cout << subgraph[e]->toString() << " ==> ";
                cout << "  cost: " << newRoute.cost << "\n";
#endif

                // If there is no nodes in this route, this route is finished.
                foreach (const VGEdge& edge, newRoute.edges)
                    newRoute.cost += subgraph[edge]->cost;

                vector<Route>& routes = allRoutes[valToRestore];
                routes.push_back(Route());
                // Swap instead of copy for performance.
                routes.back().edges.swap(newRoute.edges);

                continue;
            }

            // If this node is an operator node or function call node, add all its operands.
            if (isOperatorNode(subgraph[node]) || isFunctionCallNode(subgraph[node]))
            {
                Route& newRoute = unfinishedRoute;
                foreach (const VGEdge& edge, boost::out_edges(node, valueGraph_))
                {
                    VGVertex tar = boost::target(edge, subgraph);
                    
                    //cout << "OPERAND: " << valueGraph_[tar]->toString() << endl;

                    // The the following function returns true if adding
                    // this edge will form a circle.
                    if (hasCycle(unfinishedRoute, tar))
                        goto NEXT;
                }
                
                foreach (const VGEdge& edge, boost::out_edges(node, valueGraph_))
                {
                    VGVertex tar = boost::target(edge, subgraph);
                    newRoute.edges.push_back(edge);
                    newRoute.addVertices(tar, node);
                }
                unfinishedRoutes.push(newRoute);
                continue;
            }

            foreach (const VGEdge& edge, boost::out_edges(node, subgraph))
            {
                VGVertex tar = boost::target(edge, subgraph);
                
#if 0
                // For loop search, if the source is the mu node and the target
                // is the root, and this is the first time to traverse the mu 
                // node, then the root should not be reached.
                if (tar == ssnode_ && firstNode)
                {
                    if (PhiNode* phiNode = isPhiNode(valueGraph_[node]))
                        if (phiNode->mu)
                            continue;
                }
#endif
                
#if 0
                // If the target is an available node, go back in the stack.
                if (availableNodes.count(tar) > 0)
                //if (tar == root_ || )
                {
                    RouteWithNodes newRoute = unfinishedRoute;
                    newRoute.edges.push_back(edge);

                    // Keep removing nodes from the stack if the node before this
                    // node is its parent node.
                    VGVertex parent;
                    do
                    {
                        parent = newRoute.nodes.back().second;
                        newRoute.nodes.pop_back();
                        if (newRoute.nodes.empty()) break;
                    } while (parent == newRoute.nodes.back().first);

                    if (!newRoute.nodes.empty())
                    {
                        unfinishedRoutes.push(newRoute);
                        continue;
                    }

#if 0
                    foreach (const VGEdge& e, newRoute.edges)
                        cout << subgraph[e]->toString() << " ==> ";
                    cout << "  cost: " << newRoute.cost << "\n";
#endif
              
                    // If there is no nodes in this route, this route is finished.
                    foreach (const VGEdge& edge, newRoute.edges)
                        newRoute.cost += subgraph[edge]->cost;

                    vector<RouteWithCost>& routeWithCost = allRoutes[valToRestore];
                    routeWithCost.push_back(RouteWithCost());
                    // Swap instead of copy for performance.
                    routeWithCost.back().first.swap(newRoute.edges);
      
                    continue;
                }
#endif

                // The the following function returns true if adding
                // this edge will form a circle.
                if (hasCycle(unfinishedRoute, tar))
                    continue;

                Route newRoute = unfinishedRoute;
                newRoute.edges.push_back(edge);
                newRoute.addVertices(tar, node);
                unfinishedRoutes.push(newRoute);
            } // end of foreach (const VGEdge& edge, boost::out_edges(node, subgraph))
NEXT:
            ;//firstNode = false;
        } // end of while (!unfinishedRoutes.empty())
    } // end of foreach (VGVertex valNode, valuesToRestore)

    
    /**************************************************************************/
    // Now get the route for all state variables.
    
    // map<VGVertex, vector<RouteWithCost> > allRoutes;
    pair<int, int> path = make_pair(dagIndex, pathIndex);
    set<VGVertex>& nodesInRoute = routeNodesAndEdges_[path].first;
    //set<VGEdge>&   edgesInRoute = routeNodesAndEdges_[path].second;
    set<VGEdge> edgesInRoute;
    
    typedef map<VGVertex, vector<Route> >::value_type VertexWithRoute;
    
    // The following map stores the cost of each edge and how many times it's shared
    // by different to-store values.
    map<VGEdge, pair<int, int> > costForEdges;
    
    // Collect cost information.
    foreach (const VGEdge& edge, boost::edges(subgraph))
        costForEdges[edge] = make_pair(subgraph[edge]->cost, 0);
    
    // Make stats how many times an edge is shared by different to-store values.
    foreach (VertexWithRoute& nodeWithRoute, allRoutes)
    {
        set<VGEdge> edges;
        foreach (const Route& route, nodeWithRoute.second)
        {
            foreach (const VGEdge& edge, route.edges)
                edges.insert(edge);
        }
        
        foreach (const VGEdge& edge, edges)
        {
            //// A way to force the inverse of each function call is used.
            //if (isSgFunctionCallExp(subgraph[nodeWithRoute.first]->astNode))
            //    costForEdges[edge].second += 100;
            //else
                ++costForEdges[edge].second;
        }
    }
    

    foreach (VertexWithRoute& nodeWithRoute, allRoutes)
    {
        float minCost = std::numeric_limits<float>::max();
        size_t minIndex = 0;

        // Find the route with the minimum cost.
        for (size_t i = 0, m = nodeWithRoute.second.size(); i < m; ++i)
        {
            float cost = 0;
            
            Route& route = nodeWithRoute.second[i];
            foreach (const VGEdge& edge, route.edges)
            {
                //route.second += subgraph[edge]->cost;
                pair<int, int> costWithCounter = costForEdges[edge];
                // In this way we make an approximation of the real cost in the
                // final route graph.
                cost += float(costWithCounter.first) / costWithCounter.second;
            }
            
            if (cost < minCost)
            {
                minCost = cost;
                minIndex = i;
            }
        }

        foreach (const VGEdge& edge, nodeWithRoute.second[minIndex].edges)
        {
            nodesInRoute.insert(boost::source(edge, subgraph));
            edgesInRoute.insert(edge);
        }
        nodesInRoute.insert(ssnode_);
    }

    // End.
    /**************************************************************************/
    
    // Check if there is root node in edges set.
    bool hasRoot = false;
    foreach (const VGEdge& edge, edgesInRoute)
    {
        if (ssnode_ == boost::target(edge, subgraph))
        {
            hasRoot = true;
            break;
        }
    }
    ROSE_ASSERT(edgesInRoute.empty() || hasRoot);

    return edgesInRoute;
    
#if 0

    // To resolve the problem of binding an overloaded function.
    set<VGVertex>::const_iterator (set<VGVertex>::*findNode)
             (const set<VGVertex>::key_type&) const = &set<VGVertex>::find;
    set<VGEdge>::const_iterator (set<VGEdge>::*findEdge)
             (const set<VGEdge>::key_type&) const = &set<VGEdge>::find;
    return SubValueGraph(valueGraph_,
                         boost::bind(findEdge, &edgesInRoute, ::_1) != edgesInRoute.end(),
                         boost::bind(findNode, &nodesInRoute, ::_1) != nodesInRoute.end());
#endif
}

} // end of Backstroke
