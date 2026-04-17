/*
 * Copyright (C) 2026 Johan Pieterse
 * Plain Sailing Information Systems
 * Email: johan@plansailingisystems.co.za
 *
 * This file is part of OpenRiC.
 *
 * OpenRiC is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Ported from the Heratio ahg-ric viewer (also AGPL-3.0). Same API surface
 * — window.OpenricViewer.{init2D, init3D, fromSubgraph, getColor, COLORS}.
 *
 * This is the thin-slice precursor to the planned @openric/viewer npm
 * package. Today it lives inside the spec repo as the reference demo
 * powering https://openric.org/demo/.
 */

(function () {
  'use strict';

  // Colour scheme — covers every RiC-O class Heratio currently emits,
  // plus plain-term fallbacks.
  var COLORS = {
    RecordSet: '#4ecdc4',
    Record: '#45b7d1',
    RecordPart: '#96ceb4',
    Person: '#dc3545',
    CorporateBody: '#ffc107',
    Family: '#e83e8c',
    Production: '#6f42c1',
    Accumulation: '#5f27cd',
    Activity: '#6f42c1',
    Place: '#fd7e14',
    Thing: '#20c997',
    Concept: '#20c997',
    DocumentaryFormType: '#20c997',
    CarrierType: '#20c997',
    ContentType: '#20c997',
    RecordState: '#adb5bd',
    Language: '#0d6efd',
    Instantiation: '#17a2b8',
    Function: '#6c757d',
    Rule: '#8e44ad',
    default: '#6c757d'
  };

  function getColor(type) {
    if (!type) return COLORS.default;
    // Accept "rico:RecordSet" or "RecordSet" or full IRI.
    var local = String(type).split('#').pop().split('/').pop().split(':').pop();
    return COLORS[local] || COLORS.default;
  }

  /**
   * Adapt an OpenRiC `openric:Subgraph` response to the {nodes, edges}
   * shape the viewer consumes internally. Idempotent — passes through
   * already-adapted graphs.
   */
  function fromSubgraph(response) {
    if (!response || typeof response !== 'object') return { nodes: [], edges: [] };
    var nodes = response['openric:nodes'] || response.nodes || [];
    var edges = response['openric:edges'] || response.edges || [];
    return { nodes: nodes, edges: edges };
  }

  /**
   * Initialise a 2D Cytoscape graph in the given container.
   */
  function init2D(container, graphData, options) {
    graphData = fromSubgraph(graphData);
    if (!graphData.nodes.length || !window.cytoscape) return null;

    options = options || {};
    var nodeSize = options.nodeSize || 28;
    var fontSize = options.fontSize || '10px';
    var maxLabelLen = options.maxLabelLen || 30;

    var elements = [];

    graphData.nodes.forEach(function (node) {
      elements.push({
        data: {
          id: node.id,
          label: node.label ? String(node.label).substring(0, maxLabelLen) : 'Unknown',
          type: node.type,
          color: getColor(node.type),
          atomUrl: node.atomUrl || null
        }
      });
    });

    graphData.edges.forEach(function (edge, idx) {
      elements.push({
        data: {
          id: 'e' + idx,
          source: edge.source,
          target: edge.target,
          label: edge.label || ''
        }
      });
    });

    try {
      var cy = cytoscape({
        container: container,
        elements: elements,
        style: [
          {
            selector: 'node',
            style: {
              'background-color': 'data(color)',
              'label': 'data(label)',
              'color': '#eee',
              'font-size': fontSize,
              'text-valign': 'bottom',
              'text-margin-y': '5px',
              'width': nodeSize + 'px',
              'height': nodeSize + 'px',
              'text-wrap': 'ellipsis',
              'text-max-width': '120px'
            }
          },
          {
            selector: 'edge',
            style: {
              'width': 1,
              'line-color': '#6b7280',
              'target-arrow-color': '#6b7280',
              'target-arrow-shape': 'triangle',
              'curve-style': 'bezier',
              'label': 'data(label)',
              'font-size': '7px',
              'color': '#9ca3af',
              'text-rotation': 'autorotate'
            }
          }
        ],
        layout: {
          name: 'cose',
          animate: false,
          nodeRepulsion: function () { return options.nodeRepulsion || 5000; },
          idealEdgeLength: options.idealEdgeLength || 90,
          padding: options.padding || 20
        },
        userZoomingEnabled: true,
        userPanningEnabled: true,
        boxSelectionEnabled: false
      });

      cy.on('tap', 'node', function (evt) {
        var nodeData = evt.target.data();
        if (typeof options.onNodeClick === 'function') {
          options.onNodeClick(nodeData);
        }
      });

      return cy;
    } catch (e) {
      console.error('[OpenricViewer] 2D init error:', e);
      return null;
    }
  }

  /**
   * Initialise a 3D ForceGraph3D in the given container.
   */
  function init3D(container, graphData, options) {
    graphData = fromSubgraph(graphData);
    options = options || {};
    if (typeof ForceGraph3D === 'undefined') {
      console.error('[OpenricViewer] 3D library (ForceGraph3D) not loaded — check that https://unpkg.com/3d-force-graph@1.73.3/dist/3d-force-graph.min.js is reachable.');
      return null;
    }
    if (!graphData.nodes.length) return null;

    var nodes = graphData.nodes.map(function (n) {
      return {
        id: n.id,
        name: n.label || 'Unknown',
        color: getColor(n.type),
        val: 1,
        type: n.type,
        atomUrl: n.atomUrl || null
      };
    });
    var links = graphData.edges.map(function (e) {
      return { source: e.source, target: e.target, label: e.label || '' };
    });

    try {
      var w = container.clientWidth || 800;
      var h = container.clientHeight || 500;

      var g = ForceGraph3D()(container)
        .graphData({ nodes: nodes, links: links })
        .nodeColor('color')
        .nodeVal('val')
        .nodeLabel('name')
        .nodeThreeObject(function (node) {
          var name = node.name.length > 18 ? node.name.substring(0, 18) + '…' : node.name;
          var sprite = new SpriteText(name);
          sprite.color = '#ffffff';
          sprite.textHeight = 3;
          sprite.backgroundColor = node.color;
          sprite.padding = 0.5;
          sprite.borderRadius = 1;
          return sprite;
        })
        .nodeThreeObjectExtend(false)
        .linkDirectionalParticles(1)
        .linkLabel('label')
        .backgroundColor('#111827')
        .width(w)
        .height(h);

      if (typeof options.onNodeClick === 'function') {
        g.onNodeClick(function (node) {
          options.onNodeClick(node);
          // Nice-to-have: orbit camera to the clicked node.
          var distance = 120;
          var dist = Math.hypot(node.x || 0, node.y || 0, node.z || 0) || 1;
          g.cameraPosition(
            { x: (node.x || 0) * (distance + dist) / dist,
              y: (node.y || 0) * (distance + dist) / dist,
              z: (node.z || 0) * (distance + dist) / dist },
            node,
            800
          );
        });
      }

      return g;
    } catch (e) {
      console.error('[OpenricViewer] 3D init error:', e);
      return null;
    }
  }

  // Public API
  window.OpenricViewer = {
    COLORS: COLORS,
    getColor: getColor,
    fromSubgraph: fromSubgraph,
    init2D: init2D,
    init3D: init3D
  };
})();
