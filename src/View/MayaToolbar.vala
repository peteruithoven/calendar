//
//  Copyright (C) 2011-2012 Maxwell Barvian
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Maya.View {

    public class MayaToolbar : Gtk.HeaderBar {
        
        // Signals
        public signal void on_search (string search);
        public signal void on_menu_today_toggled ();
        public signal void add_calendar_clicked ();
        
        // Toolbar items
        Widgets.DateSwitcher month_switcher;
        Widgets.DateSwitcher year_switcher;
        public Gtk.SearchEntry search_bar;
        
        // Menu items
        Gtk.CheckMenuItem weeknumbers;
        View.SourceSelector source_selector;
        
        public MayaToolbar () {
            show_close_button = true;
            
            var button_add = new Gtk.Button.from_icon_name ("appointment-new", Gtk.IconSize.LARGE_TOOLBAR);
            button_add.tooltip_text = _("Create a new event");
            
            var button_calendar_sources = new Gtk.Button.from_icon_name ("office-calendar", Gtk.IconSize.LARGE_TOOLBAR);
            button_calendar_sources.tooltip_text = _("Manage Calendars");
            
            month_switcher = new Widgets.DateSwitcher (10);
            year_switcher = new Widgets.DateSwitcher (-1);
            var calmodel = Model.CalendarModel.get_default ();
            set_switcher_date (calmodel.month_start);
            
            search_bar = new Gtk.SearchEntry ();
            search_bar.placeholder_text = _("Search Events");
            search_bar.sensitive = false;
            
            var contractor = new Widgets.ContractorButtonWithMenu (_("Export or Share the default Calendar"));
            
            var menu = new Gtk.Menu ();
            var menu_button = new Granite.Widgets.AppMenu (menu);
            
            var title_grid = new Gtk.Grid ();
            title_grid.column_spacing = 6;
            
            title_grid.attach (year_switcher, 0, 0, 1, 1);
            title_grid.attach (month_switcher, 1, 0, 1, 1);
            this.set_custom_title (title_grid);
            
            // Create the menu
            
            var today = new Gtk.MenuItem.with_label (_("Today"));
            weeknumbers = new Gtk.CheckMenuItem.with_label (_("Show Week Numbers"));
            //var import = new Gtk.MenuItem.with_label (_("Import…"));
            var about = new Gtk.MenuItem.with_label (_("About"));
            
            // Append in correct order
            menu.add (today);
            menu.add (new Gtk.SeparatorMenuItem ());
            menu.add (weeknumbers);
            
            /* TODO : Will be done in Maya 0.2
            menu.append (new Gtk.SeparatorMenuItem ());
            menu.append (import);
            menu.append (sync);
            */
            
            menu.append (new Gtk.SeparatorMenuItem ());
            menu.append (about);
            
            pack_start (button_calendar_sources);
            pack_start (button_add);
            
            pack_end (menu_button);
            pack_end (search_bar);
            pack_end (contractor);
            
            // Connect to signals
            
            button_add.clicked.connect (() => add_calendar_clicked ());
            button_calendar_sources.clicked.connect (on_tb_sources_clicked);
            today.activate.connect (() => on_menu_today_toggled);
            weeknumbers.toggled.connect (on_menu_show_weeks_toggled);
            about.activate.connect (() => {
                var app = ((Maya.Application)GLib.Application.get_default ());
                app.show_about (app.window);
            });
            search_bar.search_changed.connect (() => on_search (search_bar.text));

            month_switcher.left_clicked.connect (() => {Model.CalendarModel.get_default ().change_month (-1);});
            month_switcher.right_clicked.connect (() => {Model.CalendarModel.get_default ().change_month (1);});
            year_switcher.left_clicked.connect (() => {Model.CalendarModel.get_default ().change_year (-1);});
            year_switcher.right_clicked.connect (() => {Model.CalendarModel.get_default ().change_year (1);});
            
            button_calendar_sources.size_allocate.connect (button_size_allocate);
            
            weeknumbers.active = saved_state.show_weeks;
            calmodel.parameters_changed.connect (() => {
                set_switcher_date (calmodel.month_start);
            });
        }

        public void set_switcher_date (DateTime date) {
            month_switcher.text = date.format ("%B");
            year_switcher.text = date.format ("%Y");
        }

        void on_menu_show_weeks_toggled () {
            saved_state.show_weeks = weeknumbers.active;
        }
        
        void button_size_allocate (Gtk.Allocation allocation) {
            month_switcher.height_request = allocation.height;
            year_switcher.height_request = allocation.height;
        }

        void on_tb_sources_clicked (Gtk.Widget widget) {
            if (source_selector == null) {
                source_selector = new View.SourceSelector ();
            }
            source_selector.move_to_widget (widget);
            source_selector.show ();
            source_selector.run ();
        }

    }

}