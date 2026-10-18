# HealthMate screen wireframes

These describe the screen structure, separate from rendered UI evidence.

```text
TODAY                          HISTORY
+--------------------------+   +--------------------------+
| HealthMate       Local   |   | HealthMate       Local   |
| Date                     |   | Your health journal      |
| A little better...       |   | All / Today / By date    |
| Streak + encouragement   |   | Date range / Clear       |
| Today at a glance        |   | Count / newest first     |
| Steps value + progress   |   | Date + values + menu     |
| Calories + progress      |   | Date + values + menu     |
| Water + progress         |   | ...scroll...             |
| Today's entries          |   |                          |
|             Log activity |   |             Log activity |
| Today History Insights ⚙ |   | Today History Insights ⚙ |
+--------------------------+   +--------------------------+

LOG / EDIT                     INSIGHTS
+--------------------------+   +--------------------------+
| Back      Log activity   |   | HealthMate       Local   |
| Entry guidance           |   | See your rhythm          |
| Date picker              |   | 7 days / 30 days         |
| Steps input              |   | Steps / Calories / Water |
| Calories input           |   | Period total + dates     |
| Water input              |   | Daily bar chart          |
| +250 / +500 / +750 ml     |   | Average / Active days    |
| Inline validation        |   | Highest day              |
| Save record              |   | Calculation explanation  |
| Input guidance           |   | Today History Insights ⚙ |
+--------------------------+   +--------------------------+

SETTINGS
+--------------------------+
| HealthMate       Local   |
| Make it yours            |
| Daily goals -> dialog    |
| Dark appearance switch   |
| Load / refresh demo      |
| Remove demo              |
| About + local data notes |
| Open-source licences     |
| Today History Insights ⚙ |
+--------------------------+
```

Navigation: bottom destinations preserve their screen state; Log activity and Edit use the same form route. Record menus provide Edit/Delete. Deletion and unsaved back navigation display confirmation dialogs. Goals use a validated dialog.
