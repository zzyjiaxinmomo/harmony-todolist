import { curves, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  scroller: Scroller = new Scroller();
  @State message: string = '';
  @State todoList: TodoListItem[] = [
    new TodoListItem("学习", false),
    new TodoListItem("上班", true),
    new TodoListItem("吃饭", true),
    new TodoListItem("打游戏", true),
    new TodoListItem("锻炼", false),
    new TodoListItem("撸猫", false),
    new TodoListItem("睡觉", false),
  ]

  build() {
    Scroll(this.scroller) {
      Column() {
        Row() {
          TextInput({ placeholder: '输入待办事项', text: this.message })
            .type(InputType.Normal)
            .backgroundColor(Color.White)
            .onChange(value => {
              this.message = value
            })
            .width('70%')
            .height(50)
          Button('提交', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor(0x317aff)
            .width(70)
            .margin({ left: 20 })
            .onClick(() => {
              this.todoList.push(new TodoListItem(this.message, false))
              this.message = ''
              promptAction.showToast({ message: '添加待办成功！' })
            })
        }.width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(20)

        Row() {
          Text("待办事项：").fontSize(36)
            .fontWeight(FontWeight.Bold)
        }.alignSelf(ItemAlign.Start)
        .padding(20)

        ForEach(this.todoList.filter(item =>!item.done), (item: TodoListItem) => {
          TodoItem({ todoItem: item, todoList: this.todoList })
        }, (item: TodoListItem): string => item.name)
        Row() {
          Text("已办事项：").fontSize(36)
            .fontWeight(FontWeight.Bold)
        }.alignSelf(ItemAlign.Start)
        .padding(20)

        ForEach(this.todoList.filter(item => item.done), (item: TodoListItem) => {
          TodoItem({ todoItem: item, todoList: this.todoList })
        }, (item: TodoListItem): string => item.name)
      }.width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .height('100%')
    .backgroundColor("#f3f3f3")
    .scrollable(ScrollDirection.Vertical) // 滚动方向为垂直方向
    .scrollBarWidth(10) // 滚动条宽度
    .scrollBar(BarState.Off) // 滚动条常驻显示
  }
}

@Observed
class TodoListItem {
  "name": string
  "done": boolean

  constructor(name: string, done: boolean) {
    this.name = name;
    this.done = done;
  }
}

@Component
struct TodoItem {
  @Link todoList: TodoListItem[]
  @ObjectLink todoItem: TodoListItem
  private effect: TransitionEffect =
    TransitionEffect.OPACITY.animation({
      curve: curves.springMotion()
    })
      .combine(TransitionEffect.translate({ y: 100 })
        .animation({ curve: curves.springMotion() }))
      .combine(TransitionEffect.move(TransitionEdge.END))

  build() {
    Row() {
      Flex() {
        Toggle({ type: ToggleType.Checkbox, isOn: this.todoItem.done })
          .margin({ right: 16 })
          .onChange((isOn: boolean) => {
            if (isOn) {
              promptAction.showToast({
                message: "已完成" + this.todoItem.name
              })
            } else {
              promptAction.showToast({
                message: "取消完成" + this.todoItem.name
              })
            }
            this.todoItem.done = isOn
            let index = this.todoList.findIndex((item) => {
              return item.name === this.todoItem.name
            })
            if (index !== -1) {
              this.todoList.splice(index, 1)
              this.todoList.push(this.todoItem)
            }
          })
        Text(this.todoItem.name)
          .fontSize(30)
          .decoration(
            this.todoItem.done ? {
              type: TextDecorationType.LineThrough,
              color: Color.Black
            } : null
          )
      }.width('75%')

      if (this.todoItem.done) {
        Button('删除').backgroundColor("#f56c6c")
          .onClick(() => {
            let index = this.todoList.findIndex((item) => {
              return item.name === this.todoItem.name
            })
            if (index !== -1) {
              this.todoList.splice(index, 1)
            }
          })
      }
    }
    .justifyContent(FlexAlign.Start)
    .alignSelf(ItemAlign.Center)
    .width('80%')
    .margin({ bottom: 16 })
    .backgroundColor(Color.White)
    .padding(20)
    .borderRadius(16)
    .transition(this.effect)
  }
}