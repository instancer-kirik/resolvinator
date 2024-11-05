from PyQt6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, 
    QTreeView, QTextEdit, QLineEdit, QComboBox, QLabel,
    QMenu, QApplication, QDialog, QCheckBox, QSpinBox
)
from PyQt6.QtCore import Qt, QJsonModel
from PyQt6.QtGui import QAction, QKeySequence
import json
import re
from typing import Any, Dict, List
import pyperclip
import logging

class JsonPathFilter:
    """JSON path filtering and manipulation"""
    def __init__(self):
        self.compiled_filters = {}
        
    def compile_filter(self, filter_expr: str) -> re.Pattern:
        """Compile filter expression into regex pattern"""
        if filter_expr not in self.compiled_filters:
            # Convert wildcard patterns to regex
            regex = filter_expr.replace(".", r"\.").replace("*", ".*")
            self.compiled_filters[filter_expr] = re.compile(regex)
        return self.compiled_filters[filter_expr]
        
    def filter_json(self, data: Any, path: str = "", filter_expr: str = "") -> Dict:
        """Filter JSON data based on path expression"""
        results = {}
        pattern = self.compile_filter(filter_expr) if filter_expr else None
        
        def _traverse(obj: Any, current_path: str):
            if isinstance(obj, dict):
                for key, value in obj.items():
                    new_path = f"{current_path}.{key}" if current_path else key
                    if not pattern or pattern.match(new_path):
                        results[new_path] = value
                    _traverse(value, new_path)
            elif isinstance(obj, list):
                for i, value in enumerate(obj):
                    new_path = f"{current_path}[{i}]"
                    if not pattern or pattern.match(new_path):
                        results[new_path] = value
                    _traverse(value, new_path)
                    
        _traverse(data, path)
        return results

class JsonExplorer(QMainWindow):
    def __init__(self):
        super().__init__()
        self.json_filter = JsonPathFilter()
        self.current_data = None
        self.setup_ui()
        
    def setup_ui(self):
        self.setWindowTitle("JSON Explorer")
        self.setGeometry(100, 100, 1200, 800)
        
        # Central widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        
        # Toolbar
        toolbar = QHBoxLayout()
        
        # Filter input
        self.filter_input = QLineEdit()
        self.filter_input.setPlaceholderText("Enter JSON path filter (e.g., data.*.name)")
        self.filter_input.returnPressed.connect(self.apply_filter)
        toolbar.addWidget(self.filter_input)
        
        # Filter type
        self.filter_type = QComboBox()
        self.filter_type.addItems(["Path", "Value", "RegEx"])
        toolbar.addWidget(self.filter_type)
        
        # Apply button
        apply_btn = QPushButton("Apply Filter")
        apply_btn.clicked.connect(self.apply_filter)
        toolbar.addWidget(apply_btn)
        
        layout.addLayout(toolbar)
        
        # Split view
        hsplitter = QHBoxLayout()
        
        # Tree view
        self.tree_view = QTreeView()
        self.tree_model = QJsonModel()
        self.tree_view.setModel(self.tree_model)
        self.tree_view.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.tree_view.customContextMenuRequested.connect(self.show_context_menu)
        hsplitter.addWidget(self.tree_view)
        
        # Text view
        self.text_view = QTextEdit()
        self.text_view.setPlaceholderText("Paste JSON here...")
        hsplitter.addWidget(self.text_view)
        
        layout.addLayout(hsplitter)
        
        # Status bar
        self.statusBar().showMessage("Ready")
        
        # Setup menu
        self.setup_menu()
        
    def setup_menu(self):
        menubar = self.menuBar()
        
        # File menu
        file_menu = menubar.addMenu("File")
        file_menu.addAction("Load JSON", self.load_json, QKeySequence.StandardKey.Open)
        file_menu.addAction("Save Filtered", self.save_filtered, QKeySequence.StandardKey.Save)
        file_menu.addSeparator()
        file_menu.addAction("Exit", self.close, QKeySequence.StandardKey.Quit)
        
        # Edit menu
        edit_menu = menubar.addMenu("Edit")
        edit_menu.addAction("Copy Path", self.copy_path, QKeySequence("Ctrl+Shift+C"))
        edit_menu.addAction("Copy Value", self.copy_value, QKeySequence("Ctrl+C"))
        edit_menu.addAction("Find", self.show_find_dialog, QKeySequence.StandardKey.Find)
        
        # View menu
        view_menu = menubar.addMenu("View")
        view_menu.addAction("Expand All", self.tree_view.expandAll)
        view_menu.addAction("Collapse All", self.tree_view.collapseAll)
        view_menu.addAction("Reset Filters", self.reset_filters)
        
        # Tools menu
        tools_menu = menubar.addMenu("Tools")
        tools_menu.addAction("Analyze Structure", self.analyze_structure)
        tools_menu.addAction("Export Schema", self.export_schema)
        tools_menu.addAction("Generate Code", self.show_code_generator)
        
    def show_context_menu(self, position):
        menu = QMenu()
        menu.addAction("Copy Path", self.copy_path)
        menu.addAction("Copy Value", self.copy_value)
        menu.addSeparator()
        menu.addAction("Filter From Here", self.filter_from_node)
        menu.addAction("Exclude This", self.exclude_node)
        menu.addSeparator()
        menu.addAction("Analyze Node", self.analyze_node)
        menu.exec(self.tree_view.viewport().mapToGlobal(position))
        
    def apply_filter(self):
        """Apply filter to current JSON data"""
        try:
            filter_text = self.filter_input.text()
            filter_type = self.filter_type.currentText()
            
            if not self.current_data:
                return
                
            if filter_type == "Path":
                filtered = self.json_filter.filter_json(
                    self.current_data, 
                    filter_expr=filter_text
                )
            elif filter_type == "Value":
                # Filter by value content
                filtered = self.filter_by_value(filter_text)
            else:  # RegEx
                filtered = self.filter_by_regex(filter_text)
                
            self.tree_model.load(filtered)
            self.statusBar().showMessage(f"Found {len(filtered)} matches")
            
        except Exception as e:
            self.statusBar().showMessage(f"Filter error: {str(e)}")
            logging.error(f"Filter error: {e}", exc_info=True)
            
    def filter_by_value(self, value_text: str) -> Dict:
        """Filter JSON by value content"""
        results = {}
        
        def _traverse(obj: Any, path: str = ""):
            if isinstance(obj, dict):
                for key, value in obj.items():
                    new_path = f"{path}.{key}" if path else key
                    if str(value).find(value_text) != -1:
                        results[new_path] = value
                    _traverse(value, new_path)
            elif isinstance(obj, list):
                for i, value in enumerate(obj):
                    new_path = f"{path}[{i}]"
                    if str(value).find(value_text) != -1:
                        results[new_path] = value
                    _traverse(value, new_path)
                    
        _traverse(self.current_data)
        return results
        
    def filter_by_regex(self, pattern: str) -> Dict:
        """Filter JSON using regular expression"""
        try:
            regex = re.compile(pattern)
            results = {}
            
            def _traverse(obj: Any, path: str = ""):
                if isinstance(obj, (str, int, float, bool)):
                    if regex.search(str(obj)):
                        results[path] = obj
                elif isinstance(obj, dict):
                    for key, value in obj.items():
                        new_path = f"{path}.{key}" if path else key
                        _traverse(value, new_path)
                elif isinstance(obj, list):
                    for i, value in enumerate(obj):
                        new_path = f"{path}[{i}]"
                        _traverse(value, new_path)
                        
            _traverse(self.current_data)
            return results
            
        except re.error as e:
            self.statusBar().showMessage(f"Invalid regex: {str(e)}")
            return {}
            
    def copy_path(self):
        """Copy selected item's path to clipboard"""
        index = self.tree_view.currentIndex()
        if index.isValid():
            path = self.tree_model.get_path(index)
            pyperclip.copy(path)
            self.statusBar().showMessage(f"Copied path: {path}")
            
    def copy_value(self):
        """Copy selected item's value to clipboard"""
        index = self.tree_view.currentIndex()
        if index.isValid():
            value = self.tree_model.data(index, Qt.ItemDataRole.DisplayRole)
            pyperclip.copy(str(value))
            self.statusBar().showMessage("Copied value to clipboard")
            
    def analyze_structure(self):
        """Analyze JSON structure and show statistics"""
        if not self.current_data:
            return
            
        stats = {
            "total_nodes": 0,
            "max_depth": 0,
            "types": {},
            "array_lengths": [],
            "key_frequencies": {}
        }
        
        def _analyze(obj: Any, depth: int = 0):
            stats["total_nodes"] += 1
            stats["max_depth"] = max(stats["max_depth"], depth)
            
            obj_type = type(obj).__name__
            stats["types"][obj_type] = stats["types"].get(obj_type, 0) + 1
            
            if isinstance(obj, dict):
                for key, value in obj.items():
                    stats["key_frequencies"][key] = stats["key_frequencies"].get(key, 0) + 1
                    _analyze(value, depth + 1)
            elif isinstance(obj, list):
                stats["array_lengths"].append(len(obj))
                for item in obj:
                    _analyze(item, depth + 1)
                    
        _analyze(self.current_data)
        
        # Show analysis dialog
        dialog = QDialog(self)
        dialog.setWindowTitle("Structure Analysis")
        layout = QVBoxLayout(dialog)
        
        text = QTextEdit()
        text.setReadOnly(True)
        text.setText(f"""
        Total Nodes: {stats['total_nodes']}
        Max Depth: {stats['max_depth']}
        
        Type Distribution:
        {json.dumps(stats['types'], indent=2)}
        
        Array Length Statistics:
        - Min: {min(stats['array_lengths']) if stats['array_lengths'] else 'N/A'}
        - Max: {max(stats['array_lengths']) if stats['array_lengths'] else 'N/A'}
        - Average: {sum(stats['array_lengths'])/len(stats['array_lengths']) if stats['array_lengths'] else 'N/A'}
        
        Most Common Keys:
        {json.dumps(dict(sorted(stats['key_frequencies'].items(), key=lambda x: x[1], reverse=True)[:10]), indent=2)}
        """)
        
        layout.addWidget(text)
        dialog.exec()