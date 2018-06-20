//
// Copyright (c) 2008-2017 the Urho3D project.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#include <Urho3D/Core/CoreEvents.h>
#include <Urho3D/Graphics/Zone.h>
#include <Urho3D/Graphics/Model.h>
#include <Urho3D/UI/Button.h>
#include <Urho3D/UI/Font.h>
#include <Urho3D/UI/Text.h>
#include <Urho3D/UI/UIEvents.h>

#include "UICustomDemo.h"
#include "UIMesh.h"

#include <Urho3D/DebugNew.h>
//=============================================================================
//=============================================================================
URHO3D_DEFINE_APPLICATION_MAIN(UICustomDemo)

UICustomDemo::UICustomDemo(Context* context)
    : Sample(context)
{
    UIMesh::RegisterObject(context);
}

void UICustomDemo::Setup()
{
    engineParameters_["WindowTitle"]   = GetTypeName();
    engineParameters_["LogName"]       = GetSubsystem<FileSystem>()->GetProgramDir() + "customUI.log";
    engineParameters_["FullScreen"]    = false;
    engineParameters_["Headless"]      = false;
    engineParameters_["WindowWidth"]   = 1280; 
    engineParameters_["WindowHeight"]  = 720;
    engineParameters_["ResourcePaths"] = "Data;CoreData;Data/CustomUI;";
}

void UICustomDemo::Start()
{
    Sample::Start();

    CreateUIMesh();

    ChangeDebugHudText();

    // show mouse
    Sample::InitMouseMode(MM_FREE);
}

void UICustomDemo::CreateUIMesh()
{
    // change background color
    GetSubsystem<Renderer>()->GetDefaultZone()->SetFogColor(Color(0.1f, 0.1f, 0.14f));
    ResourceCache* cache = GetSubsystem<ResourceCache>();
    UIElement* uiRoot = GetSubsystem<UI>()->GetRoot();

    uiRoot->SetDefaultStyle(cache->GetResource<XMLFile>("UI/DefaultStyle.xml"));

    // test 1 - don't have to specify plane.mdl any longer, but you still can use it
    UIMesh *uiMesh = new UIMesh(context_);
    uiMesh->SetMaterial(cache->GetResource<Material>("Materials/resourcebubble.xml"));
    uiMesh->SetSize(200, 200);
    uiMesh->SetPosition(100, 40);
    uiMesh->SetEnableBubbleEffect(true);
    uiRoot->AddChild(uiMesh);

    // test 2 - borderimage with custom shader
    BorderImage *borderImage = new BorderImage(context_);
    borderImage->SetMaterial(cache->GetResource<Material>("Materials/UIBackground.xml"));
    borderImage->SetSize(200, 200);
    borderImage->SetPosition(IntVector2(350, 40));
    uiRoot->AddChild(borderImage);

    // test 3 - parenting offset test
    UIElement *uie = uiRoot->CreateChild<UIElement>();
    uie->SetSize(200, 200);
    uie->SetPosition(600, 40);
    uiMesh = new UIMesh(context_);
    uiMesh->SetMaterial(cache->GetResource<Material>("Materials/UIFire.xml"));
    uiMesh->SetBlendMode(BLEND_ADDALPHA);
    uiMesh->SetSize(200, 200);
    uie->AddChild(uiMesh);

    // test 4 - using Plane.mdl, this is not necessary as stated in test 1.
    uiMesh = new UIMesh(context_);
    uiMesh->SetModel(cache->GetResource<Model>("Models/Plane.mdl"));
    uiMesh->SetMaterial(cache->GetResource<Material>("Materials/UIRimeFire.xml"));
    uiMesh->SetBlendMode(BLEND_ADDALPHA);
    uiMesh->SetSize(200, 200);
    uiMesh->SetPosition(IntVector2(850, 40));
    uiRoot->AddChild(uiMesh);

    // test 5 - model mesh
    uiMesh = new UIMesh(context_);
    uiMesh->SetModel(cache->GetResource<Model>("Models/uiWheel2.mdl"));
    uiMesh->SetTexture(cache->GetResource<Texture2D>("Textures/uiWheelcolHalfVert.png"));
    uiMesh->SetSize(200, 200);
    uiMesh->SetPosition(IntVector2(100, 290));
    uiMesh->SetScrollUV(true, Vector2(0.4f, 0.0f));
    uiRoot->AddChild(uiMesh);

    // test 6 - model mesh
    uiMesh = new UIMesh(context_);
    uiMesh->SetModel(cache->GetResource<Model>("Models/uiWheel1.mdl"));
    uiMesh->SetTexture(cache->GetResource<Texture2D>("Textures/colorCloud.png"));
    uiMesh->SetSize(200, 200);
    uiMesh->SetPosition(IntVector2(350, 290));
    uiMesh->SetScrollUV(true, Vector2(0.6f, -0.8f));
    uiRoot->AddChild(uiMesh);

    // test 7 - model mesh
    uiMesh = new UIMesh(context_);
    uiMesh->SetModel(cache->GetResource<Model>("Models/uiWheel1.mdl"));
    uiMesh->SetMaterial(cache->GetResource<Material>("Materials/UISelectWheel.xml"));
    uiMesh->SetSize(200, 200);
    uiMesh->SetPosition(IntVector2(600, 290));
    uiMesh->SetFixedUV(true, Vector2(0.2f, 0.00f));
    uiRoot->AddChild(uiMesh);

    // test 8 - button using custom shader
    SharedPtr<Material> material = (cache->GetResource<Material>("Materials/UIBackground.xml"))->Clone();
    material->SetShaderParameter("UseCircularMask", 0.0f);
    origDiffColor_ = material->GetShaderParameter("MatDiffColor").GetColor();

    Button *button = new Button(context_);
    button->SetMaterial(material);
    button->SetBlendMode(BLEND_ADDALPHA);
    button->SetSize(200, 200);
    button->SetPosition(IntVector2(850, 290));
    button->SetPressedOffset(IntVector2(0, -20));
    button->SetPressedChildOffset(IntVector2(0, 20));
    uiRoot->AddChild(button);

    Text *btnText = button->CreateChild<Text>();
    btnText->SetFont(cache->GetResource<Font>("Fonts/Anonymous Pro.ttf"), 16);
    btnText->SetColor(Color::YELLOW);
    btnText->SetText("Button\nclick me");
    btnText->SetTextAlignment(HA_CENTER);
    btnText->SetAlignment(HA_CENTER, VA_CENTER);

    SubscribeToEvent(button, E_PRESSED, URHO3D_HANDLER(UICustomDemo, HandleButtonPressed));
    SubscribeToEvent(button, E_RELEASED, URHO3D_HANDLER(UICustomDemo, HandleButtonPressed));
}

void UICustomDemo::ChangeDebugHudText()
{
    // change profiler text
    if (GetSubsystem<DebugHud>())
    {
        Text *dbgText = GetSubsystem<DebugHud>()->GetProfilerText();
        dbgText->SetColor(Color::CYAN);
        dbgText->SetTextEffect(TE_NONE);

        dbgText = GetSubsystem<DebugHud>()->GetStatsText();
        dbgText->SetColor(Color::CYAN);
        dbgText->SetTextEffect(TE_NONE);

        dbgText = GetSubsystem<DebugHud>()->GetMemoryText();
        dbgText->SetColor(Color::CYAN);
        dbgText->SetTextEffect(TE_NONE);

        dbgText = GetSubsystem<DebugHud>()->GetModeText();
        dbgText->SetColor(Color::CYAN);
        dbgText->SetTextEffect(TE_NONE);
    }
}

void UICustomDemo::HandleButtonPressed(StringHash eventType, VariantMap& eventData)
{
    using namespace Pressed;
    UIElement *uie = (UIElement*)eventData[P_ELEMENT].GetVoidPtr();
    Material *material = uie->GetMaterial();

    material->SetShaderParameter("MatDiffColor", (eventType == E_PRESSED)?Color::RED:origDiffColor_);
}

